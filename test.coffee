###$(document.body).on "pointermove", ->
  console.log(1)###

$(document).ready ->
  document.getElementById("zhazha").addEventListener("pointermove", pointerMove, false)
  ###$("#zhazha").on "pointermove", (evt)->
    console.log(evt.pressure)###

pointerMove = (evt)->
  console.log(evt.pressure)