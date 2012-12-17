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
		"click .mutesolo": "handleMuteSolo"
	initialize: () ->
		@beatsViews = []
		@model.get("beats").on 'playMe', () => @model.trigger('playMe',@model.cid)
		@model.get("beats").forEach (beat) =>
			@beatsViews.push new BeatView(model: beat)
	render: () =>
		$(@el).html @template {name: @model.get("name")}
		@beatsViews.forEach (beat) =>
			$(@el).find('.track-content').find('.beats').append beat.render()
		return @
	stopVolumeChange: (e) ->
		clearTimeout @timer
	handleMuteSolo: (e) ->
		$(e.target).toggleClass('active')
		switch $(e.target).data "action"
			when "mute"
				@model.toggle "mute"
			when "solo"
				@model.toggle "solo"
				@model.trigger('solo',@mdel.cid) if $(e.target).hasClass("active")
	changeVolume: (e) =>
		@model.changeVolume $(e.target).data('volume')
		$(@el).find('.volume').find('input').val @model.get("volume")
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
		"mousedown .tempo": "changeTempo"
		"mouseup .tempo": "stopTempoChange"
		"change #TempoControl input": "setTempo"
	initialize: () ->
		@model.get("tracks").bind 'add', @renderAdded
		@model.get("tracks").bind 'remove', @renderDel
		@model.get("tracks").bind 'reset', @renderClear
		@model.get("tracks").bind 'playMe', @play
		@model.bind 'updateMarker', @drawMarker
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
		return false if @playing is on
		@playing = true
		@model.noteTime = 0.0
		@model.startTime = @model.get("context").currentTime + 0.005
		@model.beatIndex = 0
		@model.play()
	handleStop: () ->
		@playing = false
		@model.stop()
		@clearMarkers()
	setTempo: (e) ->
		val = parseInt $(e.target).val()
		if val >= 40 && val <= 220
			@model.set "tempo", val 
		else
			@model.set "tempo", 100
			$(e.target).val "100"
	clearMarkers: () ->
		$(@el).find('#tempo').find('.Circulo').removeClass "tempo"
	changeTempo: (e) ->
		@model.changeTempo $(e.target).data('tempo')
		$(@el).find('#TempoControl').find('input').val @model.get("tempo")
		@tempoTimer = setTimeout((() => @changeTempo(e)), 25)		
	stopTempoChange: (e) ->
		clearTimeout @tempoTimer
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