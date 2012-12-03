#BeatView
class @BeatView extends Backbone.View
	template: _.template Templates.beat_view
	events: 
		"click" : "toggleStatus"
	initialize: () ->
		@model.on 'change', @render
	toggleStatus: () ->
		@model.toggleStatus()
	render: () =>
		$(@el).html @template @model.toJSON()

#TrackView
class @TrackView extends Backbone.View
	tagName: 'div'
	className: 'row'
	template: _.template Templates.track_view
	events:
		"mousedown .volume": "changeVolume"
		"mouseup .volume": "stopVolumeChange"
	initialize: () ->
		@beatsViews = []
		@model.get("beats").on 'playMe', () => @model.trigger('playMe',@model.cid)
		@model.get("beats").forEach (beat) =>
			@beatsViews.push new BeatView(model: beat)
	render: () =>
		$(@el).html @template {name: @model.get("name")}
		@beatsViews.forEach (beat) =>
			$(@el).find('.track-content').append beat.render()
		return @
	stopVolumeChange: (e) ->
		clearTimeout @timer
	changeVolume: (e) =>
		@model.changeVolume $(e.target).data('volume')
		$(@el).find('.volume').find('span').html @model.get("volume")
		@timer = setTimeout((() => @changeVolume(e)), 25)

#PatternView aka Beats
class @PatternView extends Backbone.View
	el: '#beats'
	template: _.template Templates.pattern_view
	events:
		"click .add-track": "addTrack"
		"click .del-track": "delTrack"
		"click #clear": "clearTracks"
		"click #play": "handlePlay"
		"click #stop": "handleStop"
	initialize: () ->
		@model.get("tracks").bind 'add', @renderAdded
		@model.get("tracks").bind 'remove', @renderDel
		@model.get("tracks").bind 'reset', @renderClear
		@model.get("tracks").bind 'playMe', @play
		@render()
	play: (cid) =>
		@model.playTrack(cid)	
	render: () =>
		$(@el).append @template
	clearTracks: () ->
		@model.clearTracks() if @model.tracksNumber() > 0
	addTrack: () =>
		@model.addTrack()
	delTrack: () =>
		@model.delTrack() if @model.tracksNumber() > 0
	handlePlay: () ->
		console.log "Drop the beat!"
	handleStop: () ->
		console.log "Stop that!"
	drawMarker: (index) ->
		lastIndex = (index + 15) % 16
		$("#tempo-#{index}").addClass "tempo"
		$("#tempo-#{lastIndex}").removeClass "tempo"
	renderClear: () =>
		$(@el).find('.tracks').empty()
	renderDel: (track) =>
		target = $(@el).find('.tracks').children().last()
		$(target).slideUp('slow',() => $(target).remove())
	renderAdded: (track) =>
		$(new TrackView(model: track).render().el).hide().appendTo($(@el).find('.tracks')).slideDown('slow')

###
	playPattern: () =>
		return false if @playing is on
		@playing = true
		console.log "Drop the beat!"
		#Get all tracks sound ids
		@urls = ["http://localhost:3000/samples/kick.wav"
			"http://localhost:3000/samples/snare.wav"
			"http://localhost:3000/samples/hihat.wav"
		]
		@bl = new BufferLoader(@context,@urls,@finishedLoading)
		@bl.load()
	setMarker: (i,time) ->
		console.log "Set Marker #{i} tiempo: #{time}"
		setTimeout((->
			$("#tempo-#{i}").addClass "tempo"
			if i == 1
				$("#tempo-#{16}").removeClass "tempo"
			else
				$("#tempo-#{i-1}").removeClass "tempo"
		), time*1000)		

	finishedLoading: (bufferList) =>
		beats_array = {}
		@collection.each (track) =>
			sound_id = track.get "sound_id"
			beats_array[sound_id] = track.getBeatsStatus()	
		startTime = @context.currentTime + 0.200
		tempo = 90
		beatLength = 60 / tempo / 4
		for i in [0...16]
			time = startTime  + i * beatLength
			@setMarker i+1,time - @context.currentTime		
			for id, beat_array of beats_array
				@playSound(bufferList[id],time) if beat_array[i] is on && @playing is on
		setTimeout((=>
			@finishedLoading bufferList
		), beatLength*16*1000) if @playing is on

	playSound: (buffer, time) ->
		source = @context.createBufferSource()
		source.buffer = buffer
		source.connect @context.destination	
		source.noteOn time

		source.noteOn 0
	stopPattern: () =>
		@playing = false
		console.log "Stop that!"
###