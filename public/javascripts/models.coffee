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
		url: null
		name: ""
		buffer: null
		solo: false
		mute: false
	beats: () ->
		array = []
		@get('beats').forEach (beat) ->
			if beat.get('status') is off
				array.push 0
			else
				array.push 1
		return array
	toJSON: () ->
		track = {}
		track['name'] = @get 'name'
		track['url'] = @get 'url'
		track['volume'] = @get 'volume'
		track['mute'] = @get 'mute'
		track['solo'] = @get 'solo'
		track['beats'] = @beats()
		return track
	initialize: (options) ->
		_(@get("beats_number")).times () =>
			@get("beats").add(new Beat())
	toggle: (attr) ->
		if @get(attr)
			@set attr,false
		else
			@set attr,true
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
		gainNode.gain.value = (mainGain / 100.0)
		masterGainNode = @context.createGainNode()
		masterGainNode.gain.value = sendGain / 100.0
		voice.connect gainNode
		gainNode.connect masterGainNode
		masterGainNode.connect @context.destination
		voice.noteOn(noteTime)	if mainGain > 0 && sendGain > 0

#Pattern
class @Pattern extends Backbone.Model
	defaults: () ->
		bufferLoader: null
		tracks: new Tracks()
		context: new webkitAudioContext()
		player: null
		convolver: null
		compressor: null
		masterGainNode: 80
		effectLevelNode: null
		tempo: 100
		solos: 0 #Number of tracks solo
		beats_number: 16
	initialize: () ->
		@get('tracks').bind 'solo', @newSolo
		@get('tracks').bind 'unsolo', @newUnSolo
		@set "bufferLoader", new BufferLoader(@get("context"))
		@set "player", new Player(@get("context"))
		@get("context").createBufferSource()
		@beatIndex = 0
		@lastDrawTime = -1
	saveSong: () ->
		song = {}
		song['volume'] = @get 'masterGainNode'
		song['tempo'] = @get 'tempo'
		song['solos'] = @get 'solos'
		tracks = @get('tracks')
		song['tracks'] = tracks.length
		track_number = 1
		tracks.forEach (track) ->
			song[track_number++] = track.toJSON()
		console.log JSON.stringify(song)
	addTrack: (url,name) ->
		@get("bufferLoader").loadUrl(url, (buffer) =>
			@get("tracks").add new Track({url: url, buffer: buffer, name: name})
		)
	newSolo: (id) =>
		solo = @get 'solos'
		@set 'solos', ++solo
	newUnSolo: (id) =>
		solo = @get 'solos'
		@set 'solos', --solo		
	clearTracks: () ->
		@get("tracks").reset()
	delTrack: () ->
		@get("tracks").pop()
	tracksNumber: () ->
		@get("tracks").length
	playTrack: (cid) ->
		track = @get('tracks').get cid
		@get("player").playNote(track.get("buffer"), false, 0,0,-2, @get('masterGainNode'),track.get("volume"), 1, 0);	
	changeVolume: (value) ->
		@set 'masterGainNode',value
	changeTempo: (op) ->
		tempo = @get("tempo")
		switch op
			when 'up'
				@set("tempo", ++tempo) if tempo < 220
			when 'down'
				@set("tempo", --tempo) if tempo > 40			
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
			contextPlayTime = @noteTime + @startTime;			
			@get("tracks").each (track) =>
				if track.get("beats").at(@beatIndex).get("status") is on
					@get("player").playNote(track.get("buffer"), false, 0,0,-2, @get('masterGainNode'),track.get("volume"), 1, contextPlayTime) unless track.get("mute") is on || (@get('solos') > 0 && track.get('solo') is off)
			if @noteTime != @lastDrawTime
				@lastDrawTime = @noteTime
				@.trigger 'updateMarker', (@beatIndex + 15) % 16
			@advanceNote()
		@timer = setTimeout((=>
			@play()
		), 0)
	stop: () ->
		@.trigger 'updateMarker', (@beatIndex + 15) % 16
		clearTimeout @timer


