#Templates
@Templates = {}
Templates.beat_view = """
<div class="Circulo <%= status %>"></div>
"""
Templates.track_view = """
<div class="span12 personalSpan12 track-content">	
	<div class="CuadroI">
		<h4>Instru.1</h4>
		<a class="icon-volume-mute volume" data-volume="down" href="#"></a>
		<a class="icon-volume-2 volume" data-volume="up" href="#"></a>
	</div>
</div>
"""

Templates.pattern_view = """
<div class="tracks"></div>
<div class="span12 personalSpan12 borde beats-controls">
	<div class="GrupoCuadroM">
		<div class="CuadroM">
			<a class="icon-stop" href="#"></a>
			<h5>STOP</h5>
		</div>
		<div class="CuadroM">
			<a class="icon-pause" href="#"></a>
			<h5>PAUSE</h5>
		</div>
		<div class="CuadroM">
			<a class="add-track">Add track</a>
		</div>
	</div>
	<div class="GrupoCuadroM">
		<div class="CuadroM">
			<a class="icon-download-2" href="#"></a>
			<h5>SAVE</h5>
		</div>
		<div class="CuadroM">
			<a class="icon-upload-4" href="#"></a>
			<h5>LOAD</h5>
		</div>
		<div class="CuadroM">
			<a class="icon-remove" href="#"></a>
			<h5>CLEAR</h5>
		</div>
	</div>
	<div class="GrupoCuadroM">		
		<div class="CuadroM">
			<a class="icon-volume-mute" href="#"></a>
			<h5>CLEAR</h5>
		</div>		
		<div class="CuadroM">
			<a class="icon-volume-2" href="#"></a>
			<h5>CLEAR</h5>
		</div>
	</div>				
</div>
"""

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
		return {beats: new Beats(), beats_number: 16}
	initialize: () ->
		_(@get("beats_number")).times () =>
			@get("beats").add(new Beat())	

#Tracks collection aka Pattern
class @Pattern extends Backbone.Collection
	model: Track

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
	initialize: () ->
		@collection.bind 'add', @renderAdded
	render: () =>
		$(@el).append @template
	addTrack: () =>
		@collection.add new Track()
	renderAdded: (track) =>
		$(@el).find('.tracks').append $(new TrackView(model: track).render().el)


$ ->
	pattern = new PatternView collection: new Pattern()
	pattern.render()

