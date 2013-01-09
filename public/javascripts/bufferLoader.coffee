class @BufferLoader
  constructor: (@context) ->
  loadUrl: (url,callback) ->
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
          callback(buffer)
        , (error) =>
          console.error 'decodeAudioData error', error
      )
    request.onerror = () ->
      console.log 'BufferLoader: XHR error'
    request.send()