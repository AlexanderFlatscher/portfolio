class TestCircle extends paper.Path
  constructor: (radius) ->


class LissajousCircle
  constructor: (@canvas, size, color, @wx, @wy, @omega, @lissajousPathProgress = 0, @speed = 0.5) ->
    @state = "lissajous"
    @mouseRepulsionPath = ""
    @mouseRepulsionPathProgress = 0
    @returnSpeed = 0.55

    #calculate lissajous path
    @lissajousPath = new paper.Path();
    @lissajousPath.strokeColor = "black"
    #@lissajousPath.visible = false

    for num in [0...2*Math.PI] by 0.005
      @lissajousPath.add new paper.Point((Math.sin(@wx*num+@omega) + 1) * @canvas.width / 2, (Math.sin(@wy*num+@omega) + 1) * @canvas.height / 2)

    @lissajousPath.closed = true
    @lissajousPath.simplify()

    #draw circle
    center = new paper.Point(0, 0)
    @radius = size * if @canvas.width > @canvas.height then @canvas.width else @canvas.height
    @circle = new paper.Path.Circle(center, @radius)

    (color1 = new paper.Color(color)).alpha = 0.5
    (color2 = new paper.Color(color)).alpha = 0.005
    @circle.fillColor = new paper.GradientColor new paper.Gradient([color1, color2]), center.add([@radius, -@radius]), center.add([-@radius, @radius])

  adjustToSize: (horizontalFactor, verticalFactor) ->
    for s in @lissajousPath.segments
      s.point.x *= horizontalFactor
      s.point.y *= verticalFactor

      if s.handleIn?
        s.handleIn.x *= horizontalFactor
        s.handleIn.y *= verticalFactor

      if s.handleOut?
        s.handleOut.x *= horizontalFactor
        s.handleOut.y *= verticalFactor

    f = if @canvas.width > @canvas.height then horizontalFactor else verticalFactor

    @circle.scale f
    @radius *= f
    
  raiseLissajousPathProgress: () ->
    if @lissajousPathProgress + @speed < @lissajousPath.length
      @lissajousPathProgress += @speed
    else
      @lissajousPathProgress = 0

  getNextLocation: ->
    switch @state
      when "lissajous"
        @raiseLissajousPathProgress()
        return @lissajousPath.getLocationAt(@lissajousPathProgress).point

      when "mouseRepulsion"
        t = @mouseRepulsionPathProgress
        d = @mouseRepulsionPath.length
        b = @mouseRepulsionPath.getLocationAt(0).point
        e = @mouseRepulsionPath.getLocationAt(@mouseRepulsionPath.length).point
        c = e.subtract(b)

        console.log t
        console.log d

        (c.multiply((t=t/d-1)*t*t + 1)).add(b)

        if t >= d 
          n = e
          @state = "return"
        else
          n = (c.multiply((t=t/d-1)*t*t + 1)).add(b)#(c.multiply(-Math.pow(2, -10 * t/d) + 1)).add(b)
          @mouseRepulsionPathProgress += 1#d * 0.004

        return n

      when "return"
        @raiseLissajousPathProgress()
        returnPath = new paper.Path @circle.position, @lissajousPath.getLocationAt(@lissajousPathProgress).point
        #returnPath.strokeColor = "blue"
        #console.log returnPath.length

        if returnPath.length <= 1
          @state = "lissajous"

        return returnPath.getLocationAt(@returnSpeed).point

      else
        return @lissajousPath.getLocationAt(@lissajousPathProgress).point

  getNextHue: ->
    @circle.position.x / @canvas.width * 360

  setHue: (hue) ->
    for s in @circle.fillColor.gradient.stops
      s.color.hue = hue

  setMouseRepulsion: (path) ->
    @mouseRepulsionPath = path
    @mouseRepulsionPathProgress = 0
    @state = "mouseRepulsion"

    @mouseRepulsionPath.strokeColor = "red"
    


$ ->
  filterStrength = 20
  frameTime = 0
  lastLoop = new Date
  thisLoop = 0

  bgPaper = $('#bg_paper')
  bgPaper.attr
    width: $(window).width()
    height: $(window).height()

  hueCounter = 200
  tool = new paper.Tool()
  canvas = bgPaper[0]
  paper.setup(canvas)

  background = new paper.Path.Rectangle(paper.view.bounds)
  background.fillColor = new paper.GradientColor new paper.Gradient(['#fff', '#f8f8f8']), new paper.Point(paper.view.bounds.width/2, 0), [paper.view.bounds.width/2, paper.view.bounds.height]
  
  window.circles = [
    #new LissajousCircle(canvas, 0.4, "#00AAFF", 2, 1, 3/4 * Math.PI, 4500, 0.2),
    #new LissajousCircle(canvas, 0.4, "#00AAFF", 1, 3, 1/4 * Math.PI, 1000, 0.2),
    #new LissajousCircle(canvas, 0.3, "#a2e0ff", 1, 4, 1/2 * 1/3 * Math.PI, 2000),
    #new LissajousCircle(canvas, 0.2, "#47c2ff", 4, 3, 1/3 * 1/4 * Math.PI),
    new LissajousCircle(canvas, 0.1, "#4a84a1", 3, 4, 1/3 * 3/4 * Math.PI, 1000),
    new LissajousCircle(canvas, 0.05, "#348ebb", 2, 1, Math.PI)
  ]

  paper.view.draw()



  tool.onMouseMove = (e) ->
    for c in circles
      hitResult = c.circle.hitTest e.point,
        tolerance: 50
        fill: true
        stroke: true

      if hitResult && hitResult.item
        vectorLength = 100 - (e.point.getDistance(c.circle.position) - c.radius)
        vector = ((c.circle.position.subtract(e.point)).normalize(vectorLength)).add(c.circle.position)
        c.setMouseRepulsion(new paper.Path.Line(c.circle.position, vector))
        
  ###
    mousePoint = new paper.Point(e.event.x, e.event.y)
    for c in circles
      nearestPoint = c.circle.getNearestPoint(mousePoint)
      pointDistance = mousePoint.getDistance(nearestPoint, false)
      if pointDistance < 10
        v = ((c.circle.position.subtract(mousePoint)).normalize(100 - pointDistance)).add(c.circle.position)
        c.mouseRepulsionPath = new paper.Path.Line(c.circle.position, v)
        c.mouseRepulsionPath.strokeColor = "black"
        c.state = "mouseRepulsion"###



  paper.view.onFrame = (e) ->
    if (hueCounter += 0.1) > 360
      hueCounter = 0

    for c in circles
      c.circle.position = c.getNextLocation()
      c.setHue(hueCounter)




  $(window).resize (e) ->
    w = $(window).width()
    h = $(window).height()

    oldSize = [paper.view.viewSize.width, paper.view.viewSize.height]
    newSize = paper.view.viewSize = [w, h]

    horizontalFactor = newSize[0] / oldSize[0]
    verticalFactor = newSize[1] / oldSize[1]

    background.scale horizontalFactor, verticalFactor, [0, 0]

    for c in circles
      c.adjustToSize horizontalFactor, verticalFactor



###
    thisFrameTime = (thisLoop=new Date) - lastLoop
    frameTime+= (thisFrameTime - frameTime) / filterStrength
    lastLoop = thisLoop

  fpsOut = document.getElementById('fps')
  setInterval ->
    fpsOut.innerHTML = (1000/frameTime).toFixed(1) + " fps"
  , 1000
###
    