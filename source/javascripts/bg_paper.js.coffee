return unless Modernizr.canvas #do nothing if canvas isn't available

class LissajousCircleManager
  constructor: (@canvas, @scrollTop = 0) ->
    @lissajousCircles = []
    @circleSymbols = 
      biggest:  new CircleSymbol(@canvas, 0.4, app.backgroundHue, 1, 0.5)
      big:      new CircleSymbol(@canvas, 0.3, app.backgroundHue, 1, 0.82) 
      medium:   new CircleSymbol(@canvas, 0.2, app.backgroundHue, 1, 0.64) 
      small:    new CircleSymbol(@canvas, 0.1, app.backgroundHue, 0.37, 0.46) 
      smallest: new CircleSymbol(@canvas, 0.05, app.backgroundHue, 0.56, 0.47)

    window.test = @circleSymbols

    @colorAnimation = 
      current: 0
      end: 5
      running: false


  adjustToSize: (horizontalFactor, verticalFactor) ->
    for lc in @lissajousCircles
      lc.adjustToSize horizontalFactor, verticalFactor

    for size, cs of @circleSymbols
      cs.adjustToSize horizontalFactor, verticalFactor

  applyNextAnimationStep: (delta) ->
    for lc in @lissajousCircles
      lc.circle.position = lc.getNextLocation(delta)

    if @colorAnimation.running
      last = @colorAnimation.current >= @colorAnimation.end
      for size, cs of @circleSymbols
        cs.applyColorAnimationStep(@colorAnimation.current, @colorAnimation.end, delta, last)

      if last
        @colorAnimation.running = false
      else
        @colorAnimation.current += delta

  createLissajousCircle: (size, lissajousPathData, scrollFactor, relativeVerticalOffset, lissajousPathProgress, speed) ->
    @lissajousCircles.push new LissajousCircle(@circleSymbols[size], lissajousPathData, scrollFactor, relativeVerticalOffset, lissajousPathProgress, speed)

  changeHue: (hue) ->
    @colorAnimation.running = true
    @colorAnimation.current = 0
    for size, cs of @circleSymbols
      cs.prepareColorAnimation(hue)

  mouseRepulsion: (point) ->
    for lc in @lissajousCircles
      if !lc.listenToMouseRepulsion()
        continue

      hitResult = lc.circle.hitTest point,
        tolerance: 50
        fill: true
        stroke: true

      if hitResult && hitResult.item
        lc.setMouseRepulsion point

  setScrollOffset: (top) ->
    @scrollTop = top
    for lc in @lissajousCircles
      lc.setScrollOffset(top)


    


class CircleSymbol extends paper.Symbol
  constructor: (@canvas, size, hue, saturation, lightness) ->
    @colorAnimation =
      startColor: new paper.HslColor(hue, saturation, lightness)
      currentColor: new paper.HslColor(hue, saturation, lightness)
      desiredColor: new paper.HslColor(hue, saturation, lightness)

    radius = size * if @canvas.width > @canvas.height then @canvas.width else @canvas.height
    center = new paper.Point(0,0)
    circlePath = new paper.Path.Circle(center, radius)
    color1 = new paper.HslColor(hue, saturation, lightness, 0.5)
    color2 = new paper.HslColor(hue, saturation, lightness, 0.005)
    circlePath.fillColor = new paper.GradientColor new paper.Gradient([color1, color2]), center.add([radius, -radius]), center.add([-radius, radius])

    super circlePath

  adjustToSize: (horizontalFactor, verticalFactor) ->
    f = if @canvas.width > @canvas.height then horizontalFactor else verticalFactor
    @definition.scale f

  applyColorAnimationStep: (current, end, delta, last) ->
    next = (current + delta) / end

    @colorAnimation.redStep = (@colorAnimation.desiredColor.red - @colorAnimation.currentColor.red) * next
    @colorAnimation.greenStep = (@colorAnimation.desiredColor.green - @colorAnimation.currentColor.green) * next
    @colorAnimation.blueStep = (@colorAnimation.desiredColor.blue - @colorAnimation.currentColor.blue) * next

    for s in @definition.fillColor.gradient.stops
      if last
        @colorAnimation.currentColor.red = s.color.red = @colorAnimation.desiredColor.red
        @colorAnimation.currentColor.green = s.color.green = @colorAnimation.desiredColor.green
        @colorAnimation.currentColor.blue = s.color.blue = @colorAnimation.desiredColor.blue
      else
        @colorAnimation.currentColor.red = s.color.red += @colorAnimation.redStep
        @colorAnimation.currentColor.green = s.color.green += @colorAnimation.greenStep
        @colorAnimation.currentColor.blue = s.color.blue += @colorAnimation.blueStep

  prepareColorAnimation: (hue) ->
    @colorAnimation.desiredColor.hue = hue





class LissajousCircle
  constructor: (symbol, lissajousPathData, @scrollFactor = 0, @relativeVerticalOffset = 0, @lissajousPathProgress = 0, @speed = 10) ->
    @state = "lissajous"
    @verticalOffset = @relativeVerticalOffset * ($('body').height() / 4) * @scrollFactor
    @mouseRepulsionTimer = 0
    @mouseRepulsionPathProgress = 0
    @returnPathProgress = 0
    @returnSpeed = 0
    @returnSpeedProgress = 0
    @scrollOffset = 0

    #calculate lissajous path
    @lissajousPath = new paper.Path();
    @lissajousPath.strokeColor = "black"
    @lissajousPath.visible = false

    for s in lissajousPathData.segments
      s.point.y += @verticalOffset
      @lissajousPath.add new paper.Segment(s.point, s.handleIn, s.handleOut)

    @lissajousPath.closed = true
    @lissajousPath.scale $('body').width() / 1000, $('body').height() / 4 / 1000, [0, 0]

    #place circle symbol
    @circle = symbol.place @lissajousPath.getPointAt(@lissajousPathProgress)

    @setScrollOffset $(window).scrollTop()


  adjustToSize: (horizontalFactor, verticalFactor) ->
    oldVerticalOffset = @verticalOffset
    @verticalOffset = @relativeVerticalOffset * ($('body').height() / 4) * @scrollFactor
    
    for s in @lissajousPath.segments
      s.point.x *= horizontalFactor
      s.point.y = (s.point.y - oldVerticalOffset) * verticalFactor + @verticalOffset

      if s.handleIn?
        s.handleIn.x *= horizontalFactor
        s.handleIn.y *= verticalFactor

      if s.handleOut?
        s.handleOut.x *= horizontalFactor
        s.handleOut.y *= verticalFactor

    if @state == "return"
      @calculateReturnPath()

  exportLissajousPath: ->
    JSON.stringify(@lissajousPath, ['segments', 'handleIn', 'handleOut', 'point', 'x', 'y'])

  raiseLissajousPathProgress: (amount) ->
    newProgress = @lissajousPathProgress + amount
    @lissajousPathProgress = if newProgress < @lissajousPath.length then newProgress else 0

  calculateReturnPath: (resetReturnPathProgress = true, setLissajousPathProgress = true) ->
    if @returnPath?
      @returnPath.remove()

    @returnPath = new paper.Path(@circle.position.subtract([0, @scrollOffset]).clone())
    lProgress = @lissajousPathProgress
    lStart = @lissajousPathProgress
    sampleRate = 2

    while true
      lProgress += 0.5
      lastLissajousPoint = @lissajousPath.getLocationAt(lProgress % @lissajousPath.length)
      lastLissajousPoint = lastLissajousPoint.point
      lastReturnPoint = @returnPath.lastSegment.point
      newPoint = lastLissajousPoint.subtract(lastReturnPoint).normalize(sampleRate).add(lastReturnPoint)
      @returnPath.lineTo(newPoint)

      if newPoint.getDistance(lastLissajousPoint) < 1
        break

    @returnPath.simplify()
    #@returnPath.strokeColor = "blue" 

    if resetReturnPathProgress
      @returnPathProgress = 0

    if setLissajousPathProgress
      @raiseLissajousPathProgress(lProgress - lStart)

  getNextLocation: (delta) ->
    switch @state
      when "lissajous"
        @raiseLissajousPathProgress(@speed * delta)
        #return @lissajousPath.getLocationAt(@lissajousPathProgress).point.add([0, @scrollOffset])
        return @lissajousPath.getPointAt(@lissajousPathProgress).add([0, @scrollOffset])

      when "mouseRepulsion"
        t = @mouseRepulsionPathProgress
        d = @mouseRepulsionPath.length
        b = @mouseRepulsionPath.getLocationAt(0).point
        e = @mouseRepulsionPath.getLocationAt(@mouseRepulsionPath.length).point
        c = e.subtract(b)

        @mouseRepulsionTimer++

        if t >= d 
          n = e
          @calculateReturnPath()
          @state = "return"
          @mouseRepulsionTimer = 0
        else
          n = (c.multiply((t=t/d-1)*t*t + 1)).add(b)#(c.multiply(-Math.pow(2, -10 * t/d) + 1)).add(b)
          @mouseRepulsionPathProgress += d * 0.6 * delta

        return n.add([0, @scrollOffset])

      when "return"
        if @returnPathProgress >= @returnPath.length 
          @state = "lissajous"
        
        if @returnSpeed < @speed
          @returnSpeed += 0.1
          
        @returnPathProgress += @returnSpeed * delta
        return @returnPath.getPointAt(Math.min(@returnPathProgress, @returnPath.length)).add([0, @scrollOffset])

      else
        return @lissajousPath.getLocationAt(@lissajousPathProgress).point.add([0, @scrollOffset])

  setMouseRepulsion: (point) ->
    @mouseRepulsionPath.remove() if @mouseRepulsionPath?

    point = point.subtract([0, @scrollOffset])
    cPosition = @circle.position.subtract([0, @scrollOffset])
    
    vectorLength = 100 - (point.getDistance(cPosition) - @circle.bounds.width/2)
    vector = ((cPosition.subtract(point)).normalize(vectorLength)).add(cPosition)

    @mouseRepulsionPath = new paper.Path.Line(cPosition, vector)
    @mouseRepulsionPath.strokeColor = "red"
    @mouseRepulsionPath.visible = false
    @mouseRepulsionPathProgress = 0
    @mouseRepulsionTimer = 0
    @state = "mouseRepulsion"

  setScrollOffset: (scrollTop) ->
    @scrollOffset = -scrollTop * @scrollFactor

  listenToMouseRepulsion: () ->
    return @mouseRepulsionTimer == 0 or @mouseRepulsionTimer > 15



$ ->
  ###
  stats = new Stats()
  stats.setMode(0)
  stats.domElement.style.position = 'fixed'
  stats.domElement.style.left = '0px'
  stats.domElement.style.top = '0px'
  stats.domElement.style.letterSpacing = '0px'
  document.body.appendChild(stats.domElement)
  ###

  $window = $(window)
  bgPaper = $('#bg_paper')
  bgPaper.attr
    width: $window.width()
    height: $window.height()

  canvas = bgPaper[0]
  paper.setup(canvas)
  window.lcm = new LissajousCircleManager(canvas, $window.scrollTop())

  #paint background
  background = new paper.Path.Rectangle(paper.view.bounds)
  background.fillColor = new paper.GradientColor new paper.Gradient(['#fff', '#f8f8f8']), new paper.Point(paper.view.bounds.width/2, 0), [paper.view.bounds.width/2, paper.view.bounds.height]

  paper.view.draw()

  #prepare circles
  circles = []

  $.getJSON '/javascripts/lissajous_paths.json', (data) ->
    circles.push lcm.createLissajousCircle("biggest",  data.lissajousPaths[circles.length], 0.2, 1, 1000, 5)
    circles.push lcm.createLissajousCircle("biggest",  data.lissajousPaths[circles.length], 0.2, 4, 4500, 5)
    circles.push lcm.createLissajousCircle("big",      data.lissajousPaths[circles.length], 0.4, 0.5, 4500, 8)
    circles.push lcm.createLissajousCircle("big",      data.lissajousPaths[circles.length], 0.4, 3, 3500, 8)
    circles.push lcm.createLissajousCircle("medium",   data.lissajousPaths[circles.length], 0.5, 0.5,   500)
    circles.push lcm.createLissajousCircle("medium",   data.lissajousPaths[circles.length], 0.5, 3.3, 2000)
    circles.push lcm.createLissajousCircle("small",    data.lissajousPaths[circles.length], 0.6, 0.4, 4500)
    circles.push lcm.createLissajousCircle("small",    data.lissajousPaths[circles.length], 0.6, 2.8)
    circles.push lcm.createLissajousCircle("smallest", data.lissajousPaths[circles.length], 0.9, 0.2, 0,    12)
    circles.push lcm.createLissajousCircle("smallest", data.lissajousPaths[circles.length], 0.9, 3.8, 5000, 12)
  

  # event handler
  paper.view.onFrame = (e) ->
    #stats.begin()
    scrollTop = $window.scrollTop()
    lcm.setScrollOffset(scrollTop) if scrollTop != lcm.scrollTop
    lcm.applyNextAnimationStep(e.delta)
    #stats.end()

  if not Modernizr.touch
    tool = new paper.Tool()
    tool.onMouseMove = (e) ->
      lcm.mouseRepulsion e.point

  $window.bind "sectionChange", (e) ->
    lcm.changeHue(e.hue)

  $window.resize (e) ->
    w = $window.width()
    h = $window.height()

    oldSize = [paper.view.viewSize.width, paper.view.viewSize.height]
    newSize = paper.view.viewSize = [w, h]

    horizontalFactor = newSize[0] / oldSize[0]
    verticalFactor = newSize[1] / oldSize[1]

    background.scale horizontalFactor, verticalFactor, [0, 0]

    lcm.adjustToSize horizontalFactor, verticalFactor



###
  window.calculateLissajousPaths = (canvasWidth, canvasHeight) ->
    params = [
      {wx: 2, wy: 1, omega: 3/4 * Math.PI},
      {wx: 1, wy: 3, omega: 1/4 * Math.PI}, 
      {wx: 1, wy: 4, omega: 1/2 * 1/3 * Math.PI}, 
      {wx: 4, wy: 3, omega: 1/3 * 1/4 * Math.PI}, 
      {wx: 3, wy: 4, omega: 1/3 * 3/4 * Math.PI}, 
      {wx: 2, wy: 1, omega: Math.PI}, 
      {wx: 3, wy: 4, omega: 1/3 * Math.PI}, 
      {wx: 4, wy: 3, omega: 5/8 * Math.PI}, 
      {wx: 4, wy: 3, omega: 1/3 * 3/4 * Math.PI}, 
      {wx: 2, wy: 3, omega: 1/2 * Math.PI}
    ]

    j = '{"lissajousPaths": ['
    for p in params

      lissajousPath = new paper.Path();
      lissajousPath.strokeColor = "red"

      for num in [0...2*Math.PI] by 0.001 #0.005
        lissajousPath.add new paper.Point((Math.sin(p.wx*num+p.omega) + 1) * canvasWidth / 2, ((Math.sin(p.wy*num+p.omega) + 1) * canvasHeight / 2))

      lissajousPath.closed = true
      lissajousPath.simplify()

      j += JSON.stringify(lissajousPath, ['segments', 'handleIn', 'handleOut', 'point', 'x', 'y'])
      j += ","

    j = j.substring(0, j.length - 1)
    j += "]}"

    return j
###
