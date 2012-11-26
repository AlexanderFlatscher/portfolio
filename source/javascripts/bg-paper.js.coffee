class LissajousCircle
  constructor: (@canvas, size, color, @wx, @wy, @omega, @t = 0, @speed = 0.5) ->
    
    #calculate lissajous path
    @path = new paper.Path();
    @path.strokeColor = "black"
    @path.visible = false

    for num in [0...2*Math.PI] by 0.005
      @path.add new paper.Point((Math.sin(@wx*num+@omega) + 1) * @canvas.width / 2, (Math.sin(@wy*num+@omega) + 1) * @canvas.height / 2)

    @path.closed = true
    @path.simplify()

    #draw circle
    center = new paper.Point(0, 0)
    radius = size * if canvas.width > canvas.height then canvas.width else canvas.height
    @circle = new paper.Path.Circle(center, radius)

    (color1 = new paper.Color(color)).alpha = 0.5
    (color2 = new paper.Color(color)).alpha = 0.005
    @circle.fillColor = new paper.GradientColor new paper.Gradient([color1, color2]), center.add([radius, -radius]), center.add([-radius, radius])

  adjustToSize: (horizontalFactor, verticalFactor) ->
    for s in @path.segments
      s.point.x *= horizontalFactor
      s.point.y *= verticalFactor

      if s.handleIn?
        s.handleIn.x *= horizontalFactor
        s.handleIn.y *= verticalFactor

      if s.handleOut?
        s.handleOut.x *= horizontalFactor
        s.handleOut.y *= verticalFactor

    @circle.scale if @canvas.width > @canvas.height then horizontalFactor else verticalFactor
    

  getNextLocation: ->
    if @t + @speed < @path.length
      @t += @speed
    else
      @t = 0

    return @path.getLocationAt(@t)

  getNextHue: ->
    @circle.position.x / @canvas.width * 360

  setHue: (hue) ->
    for s in @circle.fillColor.gradient.stops
      s.color.hue = hue
    


$ ->
  filterStrength = 20
  frameTime = 0
  lastLoop = new Date
  thisLoop = 0

  bgPaper = $('#bg_paper')
  bgPaper.attr
    width: $(window).width()
    height: $(window).height()

  canvas = bgPaper[0]
  paper.setup(canvas)

  background = new paper.Path.Rectangle(paper.view.bounds)
  background.fillColor = new paper.GradientColor new paper.Gradient(['#fff', '#f8f8f8']), new paper.Point(paper.view.bounds.width/2, 0), [paper.view.bounds.width/2, paper.view.bounds.height]
  
  window.circles = [
    new LissajousCircle(canvas, 0.4, "#00AAFF", 2, 1, 3/4 * Math.PI, 4500, 0.2),
    new LissajousCircle(canvas, 0.4, "#00AAFF", 1, 3, 1/4 * Math.PI, 1000, 0.2),
    new LissajousCircle(canvas, 0.2, "#47c2ff", 4, 3, 1/3 * 1/4 * Math.PI),
    new LissajousCircle(canvas, 0.3, "#a2e0ff", 1, 4, 1/2 * 1/3 * Math.PI, 2000),
    new LissajousCircle(canvas, 0.1, "#4a84a1", 3, 4, 1/3 * 3/4 * Math.PI, 1000),
    new LissajousCircle(canvas, 0.05, "#348ebb", 2, 1, Math.PI)
  ]

  paper.view.draw()

  counter = 200
  window.nav = 
    element: $('#wrapper nav')
    color: new paper.Color('#47c2ff')

  paper.view.onFrame = (e) ->
    counter += 0.1
    newHue = counter % 360

    for c in circles
      c.circle.position = c.getNextLocation().point
      c.setHue(newHue)

    nav.color.hue = newHue
    #console.log nav.color.toCssString()
    #newNavBg = nav.element.css('background').replace(/(rgba\()[0-9]{1,3}, [0-9]{1,3}, [0-9]{1,3}, ([0-1]\.[0-9]*?\) [0-9]{1,3}\%)/g, "$1#{Math.floor(nav.color.red * 255)}, #{Math.floor(nav.color.green * 255)}, #{Math.floor(nav.color.blue * 255)}, $2")
    #nav.element.css 'background', newNavBg

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
    