@Templates = {}
Templates.beat_view = """
<div class="Circulo <%= status %>"></div>
"""
Templates.track_view = """
<div class="span12 personalSpan12 track-content">
	<h4 style="text-align: center"><%= name %></h4>	
	<div class="CuadroI">
		<h4 style="text-align: center">Volume</h4>
		<div class= "elementoCuadro"> <a class="icon-volume-mute volume" data-volume="down" href="#"></a></div>
		<div class="volume elementoCuadro"><input type="text" class="dataInput" value="100"></div>
		<div class= "elementoCuadro"><a class="icon-volume-2 volume" data-volume="up" href="#"></a></div>

		<div class="mute mutesolo" data-action="mute">Mute</div>
		<div class="solo mutesolo" data-action="solo">Solo</div>
	</div>
	<div class="beats"></div>
</div>
"""

Templates.pattern_view = """
<div class="tracks"></div>
<div id="tempo">
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
<div class="span10 personalSpan12 panelcontrol">
	
	<div id="Sounds">
	    <div id="FamiliesContainer">
	    	<h4>Family</h4>
	    	<div id="Families">
		    </div>
	    </div>
        <div id="SamplesContainer">
        	<h4>Sample</h4>
	    	<div id="Samples">
		    </div>
	    </div>
	</div>
	<div id="TempoControl">
		<h4>Tempo</h4>
		<a class="icon-minus tempo down-tempo" data-tempo="down" href="#"></a>
		<div class="volume"><input id="tempoInput" type="text" value="100"></div>
		<a class="icon-plus tempo up-tempo" data-tempo="up" href="#"></a>
	</div>

    <div id="VolumeControl">
    	<h4>Volume</h4>
    	<input type="range" id="generalVolume" min="0" max="100" step="1" value="80"/>
        <span id="generalVolumeText">80</span>
    </div>
    <div id="songControl">
    	<a id="play" class="icon-play-alt" href="#"></a>
    	<a id="saveButton" class="icon-download-2" href="#"></a>
    	<a id="clear" class="icon-remove" href="#"></a>
    </div>


</div>
"""