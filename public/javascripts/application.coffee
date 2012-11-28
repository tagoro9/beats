#######Modelos#############

#Beat model
class @Beat extends Backbone.Model
	defaults:
		status: false
	toggleStatus: () ->
		if @get("status") is false
			@set "status": true
		else
			@set "status": false

#Beats collection
class @Beats extends Backbone.Collection
	model: Beat

#Track model
class @Track extends Backbone.Model
	defaults: () ->
		return {beats: new Beats(), beats_number: 16, sound_id: 1}
	initialize: (options) ->
		console.log options
		_(@get("beats_number")).times () =>
			@get("beats").add(new Beat())	
	getBeatsStatus: () ->
		beats_array = []
		@get("beats").each (beat) =>
			beats_array.push beat.get("status")
		return beats_array


#Tracks collection aka Pattern
class @Pattern extends Backbone.Collection
	model: Track

#########VISTAS################

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
		"click .volume": "changeVolume"
	initialize: () ->
		@beatsViews = []
		@model.get("beats").forEach (beat) =>
			@beatsViews.push new BeatView(model: beat)
	render: () =>
		$(@el).html @template
		@beatsViews.forEach (beat) =>
			$(@el).find('.track-content').append beat.render()
		return @
	changeVolume: (e) ->
		volume = $(e.target).data 'volume'
		console.log "Turning #{volume} the volume..."

#PatternView aka Beats
class @PatternView extends Backbone.View
	el: '#beats'
	template: _.template Templates.pattern_view
	events:
		"click .add-track": "addTrack"
		"click #play" : "playPattern"
		"click #stop": "stopPattern"
	initialize: () ->
		@trackCount = 0
		@context = new webkitAudioContext()
		@collection.bind 'add', @renderAdded
	render: () =>
		$(@el).append @template
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
			@setMarker i+1,time			
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
	addTrack: () =>
		@collection.add new Track({sound_id: @trackCount++})
	renderAdded: (track) =>
		$(@el).find('.tracks').append $(new TrackView(model: track).render().el)


$ ->
	pattern = new PatternView collection: new Pattern()
	pattern.render()

