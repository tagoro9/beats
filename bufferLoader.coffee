class BufferLoader
  constructor: (@context, @urlList, @callback, @bufferList = [], @loadCount = 0) ->
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
          @onLoad(@bufferList) if ++@loadCount == @urlList.length
        , (error) =>
          console.error 'decodeAudioData error', error
      )
    request.onerror = () ->
      alert 'BufferLoader: XHR error'
    request.send()
  load: () ->
    @urlList.forEach(url,index) ->
      @loadBuffer url,index