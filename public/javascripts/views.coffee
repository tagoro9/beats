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
	clearMarkers: () ->
		$(@el).find('#tempo').find('.Circulo').removeClass "tempo"
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