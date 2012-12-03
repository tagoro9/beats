#Beat model
class @Beat extends Backbone.Model
	defaults:
		status: false
	toggleStatus: () ->
		if @get("status") is false
			@set "status": true
			@.trigger 'playMe'	
		else
			@set "status": false		

#Beats collection
class @Beats extends Backbone.Collection
	model: Beat

#Track model
class @Track extends Backbone.Model
	defaults: () ->
		beats: new Beats()
		beats_number: 16
		volume: 100
		sound_id: 1
		name: ""
		buffer: null
	initialize: (options) ->
		_(@get("beats_number")).times () =>
			@get("beats").add(new Beat())	
	getBeatsStatus: () ->
		beats_array = []
		@get("beats").each (beat) =>
			beats_array.push beat.get("status")
		return beats_array
	changeVolume: (op) ->
		volume = @get("volume")
		switch op
			when 'up'
				@set("volume", ++volume) if volume < 100
			when 'down'
				@set("volume", --volume) if volume > 0		


#Tracks collection
class @Tracks extends Backbone.Collection
	model: Track

class @Player
	constructor: (@context) ->
	playNote: (buffer, pan, x, y, z, sendGain, mainGain, playbackRate, noteTime) ->
	    voice = @context.createBufferSource()
	    voice.buffer = buffer
	    gainNode = @context.createGainNode();
	    gainNode.gain.value = mainGain / 100.0
	    voice.connect gainNode
	    gainNode.connect @context.destination
	    voice.noteOn(noteTime)	if mainGain > 0

@context = new webkitAudioContext()
console.log context

#Pattern
class @Pattern extends Backbone.Model
	defaults: () ->
		bufferLoader: null
		tracks: new Tracks()
		context: new webkitAudioContext()
		player: null
		convolver: null
		compressor: null
		masterGainNode: null
		effectLevelNode: null
		tempo: 92
		beats_number: 16
	initialize: () ->
		@set "bufferLoader", new BufferLoader(@get("context"))
		@set "player", new Player(@get("context"))
		@get("context").createBufferSource()
		@lastDrawTime = -1
	addTrack: () ->
		@get("bufferLoader").loadUrl($('#track-url').val(), (buffer) =>
			@get("tracks").add new Track({sound_id: 0, buffer: buffer, name: $('#track-url').find(':selected').text()})
		)
	clearTracks: () ->
		@get("tracks").reset()
	delTrack: () ->
		@get("tracks").pop()
	tracksNumber: () ->
		@get("tracks").length
	playTrack: (cid) ->
		track = @get('tracks').getByCid cid
		@get("player").playNote(track.get("buffer"), false, 0,0,-2, 1,track.get("volume"), 1, 0);	
	advanceNote: () ->
		secondsPerBeat = 60.0 / @get("tempo") / 4
		@beatIndex++
		if @beatIndex == @get("beats_number")
			@beatIndex = 0
		@noteTime += secondsPerBeat
	play: () ->
		currentTime = @get("context").currentTime
		currentTime -= @startTime
		while (@noteTime < currentTime + 0.200)
			if @noteTime != @lastDrawTime
				@lastDrawTime = @noteTime
				@.trigger 'updateMarker', (@beatIndex + 15) % 16
			@advanceNote()
		@timer = setTimeout((=>
			@play()
		), 0)
	stop: () ->
		clearTimeout @timer


