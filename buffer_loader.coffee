class @BufferLoader
  constructor: (@context, @urlList, @onload, @bufferList = [], @loadCount = 0) ->
  loadBuffer: (url,index) ->
    request = new XMLHttpRequest()
    request.open "GET", url, true
    request.responseType = "arraybuffer"
    request.onload = () =>
      @context.decodeAudioData( 
        request.response,
        (buffer) =>
          if !buffer
            alert "error decoding file data: #{url}"
            return
          @bufferList[index] = buffer
          @onload(@bufferList) if ++@loadCount == @urlList.length
        , (error) ->
          console.error 'decodeAudioData error', error
      )
    request.onerror = () ->
      alert 'BufferLoader: XHR error'
    request.send()
  load: () ->
    i = 0
    for url in @urlList
      @loadBuffer url, i++