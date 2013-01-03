#BeatView
class @BeatView extends Backbone.View
	template: _.template Templates.beat_view #template renderer
	events: 
		"click" : "toggleStatus" #Handle click event on beat
	initialize: () ->
		@model.on 'change', @render #If model changes, need to render the view again
	toggleStatus: () ->
		@model.toggleStatus() #Toggle beat status in model
	render: () =>
		$(@el).html @template @model.toJSON() #send beat status to view

#TrackView
class @TrackView extends Backbone.View
	tagName: 'div'
	className: 'row' #view container class name
	template: _.template Templates.track_view #template renderer
	events:
		"mousedown .volume": "changeVolume" #hdandle volume key press
		"change .volume input": "setVolume" #handle volume text input change
		"mouseup .volume": "stopVolumeChange" #handle unpress on volume key (stop changing volume)
		"click .mutesolo": "handleMuteSolo" #handle click on mute / solo control
	initialize: () ->
		@beatsViews = [] #views for beats within the track
		@model.get("beats").on 'playMe', () => @model.trigger('playMe',@model.cid) #play sound when a beat is set
		@model.get("beats").forEach (beat) => #create all the beats views
			@beatsViews.push new BeatView(model: beat)
	render: () => #Render the track inside a div with row class
		$(@el).html @template {name: @model.get("name")}
		@beatsViews.forEach (beat) =>
			$(@el).find('.track-content').find('.beats').append beat.render() #append each beat view
		return @
	setVolume: (e) -> #volume text input change
		val = parseInt $(e.target).val()
		if val >= 0 && val <= 100 #volume must be within [0..100]
			@model.set "volume", val #upddate model
		else #handle wrong values
			@model.set "volume", 100	
			$(e.target).val "100"	
	stopVolumeChange: (e) -> #stop changing volume
		clearTimeout @timer
	handleMuteSolo: (e) ->
		$(e.target).toggleClass('active')
		switch $(e.target).data "action"
			when "mute"
				@model.toggle "mute"
			when "solo"
				@model.toggle "solo"
				@model.trigger('solo',@model.cid) if $(e.target).hasClass("active")
	changeVolume: (e) => #start changing volume
		@model.changeVolume $(e.target).data('volume')
		$(@el).find('.volume').find('input').val @model.get("volume") #update view with new value
		@timer = setTimeout((() => @changeVolume(e)), 25) #repeat every 25 miliseconds until key unpress

#PatternView aka Beats
class @PatternView extends Backbone.View
	el: '#beats'
	template: _.template Templates.pattern_view #template renderer
	events:
		"click .add-track": "addTrack" #handle add track button
		"click .del-track": "delTrack" #handle delete track button
		"click #clear": "clearTracks" #handle clear button
		"click #play": "handlePlay" #handle play button
		"click #stop": "handleStop" #handle stop button
		"mousedown .tempo": "changeTempo" #handle tempo key press
		"mouseup .tempo": "stopTempoChange" #handle tempo key unpress
		"change #TempoControl input": "setTempo" #handle tempo input change
	initialize: () ->
		$.get '/sound/family', (data) ->
			text1 = '<select id="Families"><option value="">Select family</option>'
			for family in data
				text1 = text1 + "<option value=\"#{family}\">#{family}</option>"
			text1 = text1 + '</select>'
			$('#Sounds').html(text1)
			#alert 'Load was performed.'


		$('body').on 'change', "#Families", (e) ->
			console.log "cambio" 
			$.get "/sound/samples/#{$(this).val()}", (data) ->
				$('#Samples').remove()
				text2 = '<select id="Samples">'
				for name, url of data
					text2 = text2 + "<option value=\"#{url}\">#{name}</option>"
				text2 = text2 + '</select>'
				$('#Sounds').append(text2)

		

		@model.get("tracks").bind 'add', @renderAdded #handle new track added on model
		@model.get("tracks").bind 'remove', @renderDel #handle last track removed on model
		@model.get("tracks").bind 'reset', @renderClear #handle clear all track on model
		@model.get("tracks").bind 'playMe', @play #handle play on track
		@model.bind 'updateMarker', @drawMarker #handle updateMarker event
		@render()
	play: (cid) => #start playing one track
		@model.playTrack(cid)	
	render: () => #render pattern
		$(@el).append @template
	clearTracks: () -> #clear all tracks from model
		@model.clearTracks() if @model.tracksNumber() > 0
	addTrack: () => #add new track to model
		@model.addTrack()
	delTrack: () => #delete track from model
		@model.delTrack() if @model.tracksNumber() > 0
	handlePause: () ->
		@model.stop()
		@playing = false
		$('#play').addClass 'icon-play-alt'
		$('#play').removeClass 'icon-pause'		
	handlePlay: () ->
		if @playing is on #do not play song if its already playing
			@handlePause()
			return false
		$('#play').removeClass 'icon-play-alt'
		$('#play').addClass 'icon-pause'
		@playing = true #set playing flag
		@model.noteTime = 0.0 #reset start time	
		@model.startTime = @model.get("context").currentTime + 0.005 #get current time to play
		@model.play() #play song
	handleStop: () ->
		@playing = false #clear playing flag
		@model.beatIndex = 0 #start playing from beginning	
		@model.stop() #stop playing song
		@clearMarkers()
	setTempo: (e) -> #tempo input change
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