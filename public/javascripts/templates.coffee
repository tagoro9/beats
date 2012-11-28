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
			<a id="stop" class="icon-stop" href="#"></a>
			<h5>STOP</h5>
		</div>
		<div class="CuadroM">
			<a id="play" class="icon-pause" href="#"></a>
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