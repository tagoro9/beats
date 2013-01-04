$ ->
	pattern = new PatternView model: new Pattern()
	$('.icon-twitter-2').click () ->
		window.open($(this).data('url'), 'Tweet it!', 'width=550,height=420');
	$('.playSong').click () ->
		location.href = $(this).data('url')