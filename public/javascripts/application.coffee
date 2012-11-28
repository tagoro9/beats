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
		return {beats: new Beats(), beats_number: 16, sound_id: "soy un id"}
	initialize: () ->
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
		@context = new webkitAudioContext()
		@collection.bind 'add', @renderAdded
	render: () =>
		$(@el).append @template
	playPattern: () =>
		console.log "Drop the beat!"
		#Get all tracks sound ids
		@collection.each (track) ->
			#console.log track.get 'sound_id'
			console.log track.getBeatsStatus()
		@urls = ["https://dl.dropbox.com/u/28658513/cymbal-hihat-open-stick-1.wav"]
		#@bl = new BufferLoader
	stopPattern: () =>
		console.log "Stop that!"
	addTrack: () =>
		@collection.add new Track()
	renderAdded: (track) =>
		$(@el).find('.tracks').append $(new TrackView(model: track).render().el)


$ ->
	pattern = new PatternView collection: new Pattern()
	pattern.render()

