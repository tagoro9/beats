#Beat model
class @Beat extends Backbone.Model
	defaults:
		status: false
	toggleStatus: (doIt = true) ->
		if @get("status") is false
			@set "status": true
			@.trigger 'playMe'	if doIt
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
	setBeats: (array) ->
		console.log "Setting beats #{array}"
		_(@get("beats_number")).times (i) =>
			@get("beats").at(i).toggleStatus(false) if array[i] is 1
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
		title: "No title"
		effectLevelNode: null
		tempo: 100
		solos: 0 #Number of tracks solo
		beats_number: 16
		id: 0
	initialize: () ->
		@get('tracks').bind 'solo', @newSolo
		@get('tracks').bind 'unsolo', @newUnSolo
		@set "bufferLoader", new BufferLoader(@get("context"))
		@set "player", new Player(@get("context"))
		@get("context").createBufferSource()
		@beatIndex = 0
		@lastDrawTime = -1 
		match = /.+\/(\d+)/.exec(window.location.pathname)
		if match?
			@set 'id', match[1]
			#Need to load the song
			$.get "/songs/#{@get 'id'}", @loadSong, 'json'
	loadSong: (song) =>
		console.log song
		music = JSON.parse song['music']
		#Set volume
		@set 'masterGainNode', music['volume']
		@.trigger 'updateVolume', music['volume']
		#Set tempo
		@set 'tempo', music['tempo']
		@.trigger 'updateTempo',music['tempo']
		#Set solos
		@set 'solos', music['solos']
		#Initialize tracks
		for i in [1..music['tracks']] by 1
			@addTrack music[i]['url'], music[i]['name'], music[i]
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
		songInfo = {song: {title: @get('title'), music: JSON.stringify(song)}}
		#Send song to server if it doesn't exist
		console.log "INside"
		if @get('id') == 0
			console.log "Saving song to server"
			$.post("/songs", songInfo ,(data) =>
				console.log data
				if data['success']?
					@set 'id', data['success']
					console.log @get 'id'
					@trigger 'notify', "Success", "The song was created", 'info'
				else if data['error']?
					console.log data['error']
					@trigger 'notify', "Warning", data['error'], 'error'
			, 'json')
		else
			#Update song otherwise		
			console.log "Updating song"
			$.ajax
			  url: "/songs/#{@get 'id'}",
			  type: 'PUT',
			  data: songInfo,
			  success: (data) =>
			    console.log data
			    if data['success']?
			    	@trigger 'notify', "Success", "The song was updated", 'info'
			    else if data['error']?
			    	console.log data['error']
			    	@trigger 'notify', "Warning", data['error'], 'error'
	addTrack: (url,name, array = null) ->
		@get("bufferLoader").loadUrl(url, (buffer) =>
			track = new Track({url: url, buffer: buffer, name: name})
			@get("tracks").add track
			if array?
				console.log "Update track params"
				track.set 'volume', array['volume'], {silent: true}
				track.set 'mute', array['mute'], {silent: true}
				track.set 'solo', array['solo'], {silent: true}
				track.setBeats array['beats']
				track.trigger 'loaded', array['volume'], array['mute'], array['solo']
		)
	newSolo: (id) =>
		solo = @get 'solos'
		@set 'solos', ++solo
	newUnSolo: (id) =>
		solo = @get 'solos'
		@set 'solos', --solo		
	clearTracks: () ->
		@get("tracks").reset()
	delTrack: (cid) ->
		console.log "Removing #{cid}"
		track = @get('tracks').get(cid)
		@get("tracks").remove(track)
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


