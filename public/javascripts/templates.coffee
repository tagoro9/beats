@Templates = {}
Templates.beat_view = """
<div class="Circulo <%= status %>"></div>
"""
Templates.track_view = """
<div class="span12 personalSpan12 track-content">	
	<div class="CuadroI">
		<h4><%= name %></h4>
		<div class="volume"><span>100</span></div>
		<a class="icon-volume-mute volume" data-volume="down" href="#"></a>
		<a class="icon-volume-2 volume" data-volume="up" href="#"></a>
	</div>
</div>
"""

Templates.pattern_view = """
<div class="tracks"></div>
<div id="tempo" class="span12 personalSpan12">
	<div class="CuadroI">
		<a class="icon-plus add-track" href="#"></a>
		<a class="icon-minus del-track" href="#"></a>
		<select id="track-url" style="width: 80px; margin-top: 20px;">
			<option value="http://localhost:3000/samples/kick.wav">Kick</option>
			<option value="http://localhost:3000/samples/snare.wav">Snare</option>
			<option value="http://localhost:3000/samples/hihat.wav">Hihat</option>
		</select>
	</div>
	<div id="tempo-0" class="Circulo "></div>
	<div id="tempo-1" class="Circulo "></div>
	<div id="tempo-2" class="Circulo "></div>
	<div id="tempo-3" class="Circulo "></div>
	<div id="tempo-4" class="Circulo "></div>
	<div id="tempo-5" class="Circulo "></div>
	<div id="tempo-6" class="Circulo "></div>
	<div id="tempo-7" class="Circulo "></div>
	<div id="tempo-8" class="Circulo "></div>
	<div id="tempo-9" class="Circulo "></div>
	<div id="tempo-10" class="Circulo "></div>
	<div id="tempo-11" class="Circulo "></div>
	<div id="tempo-12" class="Circulo "></div>
	<div id="tempo-13" class="Circulo "></div>
	<div id="tempo-14" class="Circulo "></div>
	<div id="tempo-15" class="Circulo "></div>
</div>
<div class="span12 personalSpan12 borde beats-controls">
	<div class="GrupoCuadroM">
		<div class="CuadroM">
			<a id="stop" class="icon-stop" href="#"></a>
			<h5>STOP</h5>
		</div>
		<div class="CuadroM">
			<a id="play" class="icon-play-alt" href="#"></a>
			<h5>PAUSE</h5>
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
			<a id="clear" class="icon-remove" href="#"></a>
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