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
		beats: new Beats()
		beats_number: 16
		sound_id: 1
		buffer: null
	initialize: (options) ->
		_(@get("beats_number")).times () =>
			@get("beats").add(new Beat())	
	getBeatsStatus: () ->
		beats_array = []
		@get("beats").each (beat) =>
			beats_array.push beat.get("status")
		return beats_array


#Tracks collection
class @Tracks extends Backbone.Collection
	model: Track

class @Player

#Pattern
class @Pattern extends Backbone.Model
	defaults: () ->
		bufferLoader: new BufferLoader()
		tracks: new Tracks()
		context: new webkitAudioContext()
		player: new Player()
	addTrack: () ->
		@get("tracks").add new Track({sound_id: 0})
	clearTracks: () ->
		@get("tracks").reset()
	delTrack: () ->
		@get("tracks").pop()
	tracksNumber: () ->
		@get("tracks").length