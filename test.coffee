
class window.atTest
  zhazha: 123

  setup: ->
    @showText()

  showText: ->
    this.kela = 90
    _self = this
    yiyi = 60
    $("#myCanvas").on "click", ->
      $("#myCanvas").each ->
        alert(yiyi)

$(document).ready ->
  test = new atTest()
  test.setup()
  #loadFile(null)

###pointerMove = (evt)->
  null###


WebPDecodeAndDraw = (data)->
  canvas = document.getElementById("myCanvas")
  WebPImage = {width: {value: 0}, height: {value: 0}}
  decoder = new WebPDecoder()

  data = convertBinaryToArray(data)

  config = decoder.WebPDecoderConfig
  output_buffer = config.j
  bitStream = config.input

  if (!decoder.WebPInitDecoderConfig(config))
    return false

  statusCode = decoder.VP8StatusCode
  status = decoder.WebPGetFeatures(data, data.length, bitStream)

  if (status != 0)
    console.log('status error')

  mode = decoder.WEBP_CSP_MODE
  output_buffer.J = 4
  status = decoder.WebPDecode(data, data.length, config)

  ok = (status == 0)
  if (!ok)
    console.log("Decoding of %s failed.\n")
    return false

  bitmap = output_buffer.c.RGBA.ma
  if (bitmap)
    biHeight = output_buffer.height
    biWidth = output_buffer.width

    canvas.height = biHeight
    canvas.width = biWidth

    context = canvas.getContext('2d')
    output = context.createImageData(canvas.width, canvas.height)
    outputData = output.data

    for h in [0...biHeight]
      for w in [0...biWidth]
        outputData[0 + w * 4 + (biWidth * 4) * h] = bitmap[1 + w * 4 + (biWidth * 4) * h];
        outputData[1 + w * 4 + (biWidth * 4) * h] = bitmap[2 + w * 4 + (biWidth * 4) * h];
        outputData[2 + w * 4 + (biWidth * 4) * h] = bitmap[3 + w * 4 + (biWidth * 4) * h];
        outputData[3 + w * 4 + (biWidth * 4) * h] = bitmap[0 + w * 4 + (biWidth * 4) * h];
    context.putImageData(output, 0, 0)

loadFile = (type)->
  if (!type)
    type = 'dec'
  http = new XMLHttpRequest()
  if (type == 'dec')
    http.open('get', '1.webp')
    if(http.overrideMimeType)
      http.overrideMimeType('text/plain; charset=x-user-defined')
    else
      http.setRequestHeader('Accept-Charset', 'x-user-defined')

    http.onreadystatechange = ->
      if(http.readyState == 4)
        if (!http.responseBody)
          response = http.responseText.split('').map((e)->
            String.fromCharCode(e.charCodeAt(0) & 0xff)
          ).join('')
        else
          response = convertResponseBodyToText(http.responseBody)
        if (type == 'dec')
          WebPDecodeAndDraw(response)
    http.send(null)
  else if (type == 'enc')
    ImageToCanvas('/images-enc/1.webp')


convertResponseBodyToText = (IEByteArray)->
  ByteMapping = {}
  for i in [0...256]
    for j in [0...256]
      ByteMapping[String.fromCharCode(i + j * 256)] = String.fromCharCode(i) + String.fromCharCode(j)

  rawBytes = IEBinaryToArray_ByteStr(IEByteArray)
  lastChr = IEBinaryToArray_ByteStr_Last(IEByteArray)
  rawBytes.replace(/[\s\S]/g, (match)->
    ByteMapping[match]
  ) + lastChr

convertBinaryToArray = (binary)->
  arr = new Array()
  num = binary.length
  for i in [0...num]
    arr.push(binary.charCodeAt(i))
  arr


