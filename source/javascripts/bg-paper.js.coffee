$ ->
  $('#bg-paper').attr
    width: $(window).width()/2
    height: $(window).height()

  console.log $('#bg-paper').attr 'width'

  canvas = $('#bg-paper')[0]
  paper.setup(canvas)
  console.log $('#bg-paper').attr 'width'

  path = new paper.Path()
  path.strokeColor = "blue"

  start = new paper.Point(100, 100)
  path.moveTo start
  path.lineTo start.add([100, 300])

  paper.view.draw()

  paper.view.onFrame = (e) ->
    path.rotate 3
    