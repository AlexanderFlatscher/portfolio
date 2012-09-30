class LissajousCircle
  constructor: (@canvas, size, color, @wx, @wy, @omega, @t = 0, @speed = 0.5) ->
    
    #calculate lissajous path
    @path = new paper.Path();
    @path.strokeColor = "black"
    @path.visible = false

    for num in [0...2*Math.PI] by 0.01
      @path.add new paper.Point((Math.sin(@wx*num+@omega) + 1) * @canvas.width / 2, (Math.sin(@wy*num+@omega) + 1) * @canvas.height / 2)

    @path.closed = true
    @path.simplify()

    #draw circle
    @circle = new paper.Path.Circle(new paper.Point(0, 0), canvas.width * size)
    @circle.fillColor = color
    @circle.opacity = 0.3

  getNextLocation: ->
    if @t + @speed < @path.length
      @t += @speed
    else
      @t = 0

    return @path.getLocationAt(@t)

  getNextHue: ->
    @circle.position.x / @canvas.width * 360
    


$ ->
  filterStrength = 20
  frameTime = 0
  lastLoop = new Date
  thisLoop = 0


  $('#bg-paper').attr
    width: $(window).width()
    height: $(window).height()

  canvas = $('#bg-paper')[0]
  paper.setup(canvas)

  background = new paper.Path.Rectangle(paper.view.bounds)
  background.fillColor = "white"

  circles = [
    new LissajousCircle(canvas, 0.4, "#00AAFF", 3, 1, 1/2 * Math.PI),
    new LissajousCircle(canvas, 0.2, "#AAFF00", 4, 3, 1/3 * 1/4 * Math.PI),
    new LissajousCircle(canvas, 0.3, "#FFAA00", 1, 4, 1/2 * 1/3 * Math.PI, 2000),
    new LissajousCircle(canvas, 0.1, "#AA00FF", 3, 4, 1/3 * 3/4 * Math.PI, 1000),
    new LissajousCircle(canvas, 0.05, "#FF00AA", 2, 1, Math.PI)
  ]
  ###circles = [
    new LissajousCircle(canvas, 0.4, "green", 4, 3, 1/3 * 1/4 * Math.PI),
    new LissajousCircle(canvas, 0.2, "blue", 1, 4, 1/2 * 1/3 * Math.PI),
    new LissajousCircle(canvas, 0.3, "yellow", 3, 4, 1/3 * 3/4 * Math.PI, 2000),
    new LissajousCircle(canvas, 0.3, "pink", 3, 1, 1/4 * Math.PI, 1000),
    new LissajousCircle(canvas, 0.1, "red", 3, 1, 1/2 * Math.PI),
    new LissajousCircle(canvas, 0.05, "pink", 2, 1, Math.PI)
  ]###

  paper.view.draw()

  counter = 200

  paper.view.onFrame = (e) ->
    counter += 0.01
    for c in circles
      c.circle.position = c.getNextLocation().point
      #c.circle.fillColor.hue = counter % 360

    thisFrameTime = (thisLoop=new Date) - lastLoop
    frameTime+= (thisFrameTime - frameTime) / filterStrength
    lastLoop = thisLoop

  fpsOut = document.getElementById('fps')
  setInterval ->
    fpsOut.innerHTML = (1000/frameTime).toFixed(1) + " fps"
  , 1000

    