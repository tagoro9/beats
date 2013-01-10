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
		@model.on 'loaded', @updateTrack
		@beatsViews = [] #views for beats within the track
		@model.get("beats").on 'playMe', () => @model.trigger('playMe',@model.cid) #play sound when a beat is set
		@model.get("beats").forEach (beat) => #create all the beats views
			@beatsViews.push new BeatView(model: beat)
	render: () => #Render the track inside a div with row class
		mute =  if @model.get('mute') then "active" else ""
		solo = if @model.get('solo') then "active" else ""
		cid = @model.cid
		$(@el).html @template {name: @model.get("name"), volume: @model.get('volume'), solo: solo, mute: mute, cid: cid}
		@beatsViews.forEach (beat) =>
			$(@el).find('.track-content').find('.beats').append beat.render() #append each beat view
		return @
	updateTrack: (volume,mute,solo) =>
		$(@el).find('.volume').find('input').val volume
		$(@el).find('.mute').addClass 'active' if mute
		$(@el).find('.solo').addClass 'active' if solo
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
				if $(e.target).hasClass("active")
					@model.trigger('solo',@model.cid) 
				else
					@model.trigger('unsolo',@model.cid)
	changeVolume: (e) => #start changing volume
		@model.changeVolume $(e.target).data('volume')
		$(@el).find('.volume').find('input').val @model.get("volume") #update view with new value
		@timer = setTimeout((() => @changeVolume(e)), 25) #repeat every 25 miliseconds until key unpress

#PatternView aka Beats
class @PatternView extends Backbone.View
	el: '#beats'
	template: _.template Templates.pattern_view #template renderer
	events:
		#"click .add-track": "addTrack" #handle add track button
		"click #saveButton": "saveSong" #event to send song to server
		"click .del-track": "delTrack" #handle delete track button
		"click #clear": "clearTracks" #handle clear button
		"click #play": "handlePlay" #handle play button
		"click #stop": "handleStop" #handle stop button
		"mousedown a.tempo": "changeTempo" #handle tempo key press
		"mouseup a.tempo": "stopTempoChange" #handle tempo key unpress
		"change #TempoControl input": "setTempo" #handle tempo input change
		"change #generalVolume": "handleGenVolumeChange" #Cahnge general volume slider
	initialize: () ->
		$.get '/sound/family', (data) ->
			text1 = '<ul>'
			for family in data
				text1 = text1 + "<li><a href=\"/sound/samples/#{family}\" class=\"Family\">#{family}</a></li>"
			text1 = text1 + '</ul>'
			$('#Families').html(text1)
			#alert 'Load was performed.'

		$('body').on 'click', ".Family", (e) ->
			e.preventDefault()
			$.get "#{$(this).attr("href")}", (data) ->
				#$('#Samples').remove()
				text2 = '<ul>'
				for name, url of data
					text2 = text2 + "<li><a class=\"sampleLink\" href=\"#\" data-name=\"#{name}\" data-url=\"#{url}\">#{name}</a></li>"
				text2 = text2 + '</ul>'
				$('#Samples').html(text2)

		$('body').on 'click', '.sampleLink', (e) =>
			e.preventDefault()
			@addTrack $(e.target).data('url'), $(e.target).data('name')
			return false;
		@model.get("tracks").bind 'add', @renderAdded #handle new track added on model
		@model.get("tracks").bind 'remove', @renderDel #handle last track removed on model
		@model.get("tracks").bind 'reset', @renderClear #handle clear all track on model
		@model.get("tracks").bind 'playMe', @play #handle play on track
		@model.bind 'updateMarker', @drawMarker #handle updateMarker event
		@model.bind 'updateTempo', @updateTempo
		@model.bind 'updateVolume', @updateVolume
		@model.bind 'notify', @notify
		@render()
	notify: (title, message, type) ->
		$.pnotify { title: title, text: message, pnotify_history: false, pnotify_type: type, styling: 'jqueryui'}
	updateTempo: (tempo) =>
		$('#tempoInput').val tempo
	updateVolume: (volume) =>
		$('#generalVolumeText').html volume
		$('#generalVolume').val volume
	saveSong: () -> #save song to server
		@model.saveSong()
	play: (cid) => #start playing one track
		@model.playTrack(cid)	
	render: () => #render pattern
		$(@el).append @template
	clearTracks: () -> #clear all tracks from model
		@model.clearTracks() if @model.tracksNumber() > 0
	addTrack: (url,name) => #add new track to model
		@model.addTrack(url,name)
	delTrack: (e) -> #delete track from model
		e.preventDefault()
		console.log $(e.target).html()
		@model.delTrack($(e.target).data('cid')) if @model.tracksNumber() > 0
	handleGenVolumeChange: (e) ->
		volume = $(e.target).val()
		$('#generalVolumeText').html(volume)
		@model.changeVolume volume
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
		target = $(@el).find("##{track.cid}").parent()
		$(target).slideUp('slow',() => $(target).remove())
	renderAdded: (track) =>
		$(new TrackView(model: track).render().el).appendTo($(@el).find('.tracks'))