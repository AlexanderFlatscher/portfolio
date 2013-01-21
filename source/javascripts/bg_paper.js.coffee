class LissajousCircle
  #constructor: (@canvas, size, hue, saturation, lightness, opacity, @wx, @wy, @omega, @scrollFactor = 0, @verticalOffset = 0, @lissajousPathProgress = 0, @speed = 0.5) ->
  constructor: (@canvas, lissajousPathData, size, hue, saturation, lightness, opacity, @scrollFactor = 0, @verticalOffset = 0, @lissajousPathProgress = 0, @speed = 0.5) ->
    @state = "lissajous"
    @mouseRepulsionTimer = 0
    @mouseRepulsionPathProgress = 0
    @returnPathProgress = 0
    @returnSpeed = 0
    @returnSpeedProgress = 0
    @scrollOffset = 0
    @colorAnimation =
      initialColor: new paper.HslColor(hue, saturation, lightness)
      currentColor: new paper.HslColor(hue, saturation, lightness)
      desiredColor: new paper.HslColor(hue, saturation, lightness)

    #calculate lissajous path
    @lissajousPath = new paper.Path();
    @lissajousPath.strokeColor = "black"
    #@lissajousPath.visible = false

    for s in lissajousPathData.segments
      #@lissajousPath.add new paper.Point(s.point) #new paper.Segment(s.point, s.handleIn, s.handleOut)
      @lissajousPath.lineTo new paper.Point(s.point) #new paper.Segment(s.point, s.handleIn, s.handleOut)

    @lissajousPath.closed = true

    #@lissajousPath.scale @canvas.width / 1000, @canvas.height / 1000, [0, 0]
    #@lissajousPath.simplify()
    #@lissajousPath.smooth()

    #for num in [0...2*Math.PI] by 0.005
    #  @lissajousPath.add new paper.Point((Math.sin(@wx*num+@omega) + 1) * @canvas.width / 2, ((Math.sin(@wy*num+@omega) + 1) * @canvas.height / 2) + @verticalOffset * @canvas.height)
    #
    #@lissajousPath.closed = true
    #@lissajousPath.simplify()

    #draw circle
    center = new paper.Point(0, @verticalOffset * @canvas.height)
    @radius = size * if @canvas.width > @canvas.height then @canvas.width else @canvas.height
    @circle = new paper.Path.Circle(center, @radius)

    color1 = new paper.HslColor(hue, saturation, lightness, 0.5)
    color2 = new paper.HslColor(hue, saturation, lightness, 0.005)
    @circle.fillColor = new paper.GradientColor new paper.Gradient([color1, color2]), center.add([@radius, -@radius]), center.add([-@radius, @radius])
    @circle.position = @lissajousPath.getPointAt(@lissajousPathProgress)

    #@circle.opacity = opacity

    @setScrollOffset $(window).scrollTop()

  exportLissajousPath: ->
    JSON.stringify(@lissajousPath, ['segments', 'handleIn', 'handleOut', 'point', 'x', 'y'])

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
    
  raiseLissajousPathProgress: (amount) ->
    @lissajousPathProgress = (@lissajousPathProgress + amount) % @lissajousPath.length

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
          @mouseRepulsionPathProgress += d * 0.01 * delta

        return n.add([0, @scrollOffset])

      when "return"
        if @returnPathProgress >= @returnPath.length 
          @state = "lissajous"
        
        if @returnSpeed < @speed
          @returnSpeed += 0.01
          
        @returnPathProgress += @returnSpeed * delta
        return @returnPath.getPointAt(Math.min(@returnPathProgress, @returnPath.length)).add([0, @scrollOffset])

      else
        return @lissajousPath.getLocationAt(@lissajousPathProgress).point.add([0, @scrollOffset])

  getNextHue: ->
    @circle.position.x / @canvas.width * 360

  setHue: (hue) ->
    for s in @circle.fillColor.gradient.stops
      s.color.hue = hue

  setMouseRepulsion: (point) ->
    @mouseRepulsionPath.remove() if @mouseRepulsionPath?

    point = point.subtract([0, @scrollOffset])
    cPosition = @circle.position.subtract([0, @scrollOffset])
    
    vectorLength = 100 - (point.getDistance(cPosition) - @radius)
    vector = ((cPosition.subtract(point)).normalize(vectorLength)).add(cPosition)

    @mouseRepulsionPath = new paper.Path.Line(cPosition, vector)
    @mouseRepulsionPathProgress = 0
    @mouseRepulsionTimer = 0
    @state = "mouseRepulsion"

    @mouseRepulsionPath.strokeColor = "red"
    @mouseRepulsionPath.visible = false

  setScrollOffset: (scrollTop) ->
    @scrollOffset = -scrollTop * @scrollFactor

  listenToMouseRepulsion: () ->
    return @mouseRepulsionTimer == 0 or @mouseRepulsionTimer > 15


  prepareColorAnimationTo: (hue) ->
    @colorAnimation.desiredColor.hue = hue

    @colorAnimation.redStep = (@colorAnimation.desiredColor.red - @colorAnimation.currentColor.red) / (app.colorAnimation.end - app.colorAnimation.current)
    @colorAnimation.greenStep = (@colorAnimation.desiredColor.green - @colorAnimation.currentColor.green) / (app.colorAnimation.end - app.colorAnimation.current)
    @colorAnimation.blueStep = (@colorAnimation.desiredColor.blue - @colorAnimation.currentColor.blue) / (app.colorAnimation.end - app.colorAnimation.current)

  applyColorAnimationStep: (last = false) ->
    if not @colorAnimation.currentColor.equals(@colorAnimation.desiredColor)
      for s in @circle.fillColor.gradient.stops
        if last
          @colorAnimation.currentColor.red = s.color.red = @colorAnimation.desiredColor.red
          @colorAnimation.currentColor.green = s.color.green = @colorAnimation.desiredColor.green
          @colorAnimation.currentColor.blue = s.color.blue = @colorAnimation.desiredColor.blue
        else
          @colorAnimation.currentColor.red = s.color.red += @colorAnimation.redStep
          @colorAnimation.currentColor.green = s.color.green += @colorAnimation.greenStep
          @colorAnimation.currentColor.blue = s.color.blue += @colorAnimation.blueStep
   
class ProgressBar
  constructor: (canvas, height) ->
    @progress = 0
    @currentWidth = 0
    @fullWidth = canvas.width
    @fullHeight = canvas.height
    @expandProgress = 0
    @expandEnd = 50

    progressBarPoint = new paper.Point(0, canvas.height/2 - height/2)
    progressBarSize = new paper.Size(0, height)
    @rectangle = new paper.Path.Rectangle(progressBarPoint, progressBarSize)
    @rectangle.fillColor = "#00AAFF"
    @rectangle.fillColor.alpha = 0.5

  setProgress: (p) ->
    @progress = p
    @setRectangleWidth(@fullWidth * p/100)

  setRectangleWidth: (width) ->
    @rectangle.segments[2].point.x = @rectangle.segments[3].point.x = width

  adjustToSize: (hor, ver) ->
    currentWidth = @rectangle.segments[2].point.x
    @setRectangleWidth(currentWidth * hor)
    @fullWidth *= hor

    @fullHeight *= ver
    @rectangle.position.y *= ver

  isFinished: ->
    return @progress == 100

  expandVertically: ->
    if not @isFullyExpanded()
      stepSize = (@fullHeight - 20) / 2 / @expandEnd
      @rectangle.segments[0].point.y += stepSize
      @rectangle.segments[3].point.y += stepSize

      @rectangle.segments[1].point.y -= stepSize
      @rectangle.segments[2].point.y -= stepSize

      @rectangle.opacity -= 1/@expandEnd
      @expandProgress++
    else
      console.error "already fully expanded"

  isFullyExpanded: ->
    return @expandProgress == @expandEnd

  destroy: ->
    @rectangle.remove()


$ ->
  stats = new Stats()
  stats.setMode(0)
  stats.domElement.style.position = 'fixed'
  stats.domElement.style.left = '0px'
  stats.domElement.style.top = '0px'
  stats.domElement.style.letterSpacing = '0px'
  document.body.appendChild(stats.domElement)

  bgPaper = $('#bg_paper')
  bgPaper.attr
    width: $(window).width()
    height: $(window).height()

  tool = new paper.Tool()
  canvas = bgPaper[0]
  paper.setup(canvas)

  #paint background
  background = new paper.Path.Rectangle(paper.view.bounds)
  background.fillColor = new paper.GradientColor new paper.Gradient(['#fff', '#f8f8f8']), new paper.Point(paper.view.bounds.width/2, 0), [paper.view.bounds.width/2, paper.view.bounds.height]

  #paint progressbar
  window.progressBar = new ProgressBar(canvas, 20)

  paper.view.draw()

  #prepare circles
  window.circles = []
  #circlesInstructions = []
  onFrameAnimationState = onFrameInstructions = lissajousPathData = undefined

  $.getJSON '/javascripts/lissajous_paths.json', (data) ->
    console.log data

    #circlesInstructions.push ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.4, app.backgroundHue, 1, 0.5, 0, 0.2, 0.5, 4500, 0.2)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.4, app.backgroundHue, 1, 0.5, 0, 0.2, 0, 1000, 0.2)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.3, app.backgroundHue, 1, 0.82, 0, 0.4, 0.3, 2000)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.2, app.backgroundHue, 1, 0.64, 0, 0.5)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.1, app.backgroundHue, 0.37, 0.46, 0, 0.6, 0.2, 1000)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.05, app.backgroundHue, 0.56, 0.47, 0, 0.9, 0.2)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.05, app.backgroundHue, 0.56, 0.47, 0, 0.9, 1.5, 5000, 0.6)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.2, app.backgroundHue, 1, 0.64, 0, 0.5, 1.5)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.1, app.backgroundHue, 0.37, 0.46, 0, 0.6, 1.5)
    #, ->
    #  circles.push new LissajousCircle(canvas, lissajousPathData[circles.length], 0.3, app.backgroundHue, 1, 0.82, 0, 0.4, 0.6, 2000)

    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.4, app.backgroundHue, 1, 0.5, 0, 0.2, 0.5, 4500, 50.2)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.4, app.backgroundHue, 1, 0.5, 0, 0.2, 0, 1000, 0.2)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.3, app.backgroundHue, 1, 0.82, 0, 0.4, 0.3, 2000)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.2, app.backgroundHue, 1, 0.64, 0, 0.5)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.1, app.backgroundHue, 0.37, 0.46, 0, 0.6, 0.2, 1000)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.05, app.backgroundHue, 0.56, 0.47, 0, 0.9, 0.2)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.05, app.backgroundHue, 0.56, 0.47, 0, 0.9, 1.5, 5000, 0.6)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.2, app.backgroundHue, 1, 0.64, 0, 0.5, 1.5)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.1, app.backgroundHue, 0.37, 0.46, 0, 0.6, 1.5)
    circles.push new LissajousCircle(canvas, data.lissajousPaths[circles.length], 0.3, app.backgroundHue, 1, 0.82, 0, 0.4, 0.6, 2000)
  
  #define animations
  onFrameAnimationState = "circles"
  onFrameInstructions = 
    circles: (delta) ->
      for c in circles
        c.circle.position = c.getNextLocation(delta) #progressIncrease
        
        if app.colorAnimation.isRunning()
          if app.colorAnimation.isFirstStep()
            c.prepareColorAnimationTo(app.backgroundHue)
          c.applyColorAnimationStep(app.colorAnimation.isLastStep())

      app.colorAnimation.current++ if app.colorAnimation.isRunning()

    progressBar: ->
      circlesInstructions[circles.length]()
      progressBar.setProgress(circles.length * 100)

      if progressBar.isFinished()
        onFrameAnimationState = "removeProgressBar"
    removeProgressBar: ->
      this.circles()
      progressBar.expandVertically()

      for c in circles
        c.circle.opacity = 1 - progressBar.rectangle.opacity

      if progressBar.isFullyExpanded()
        onFrameAnimationState = "circles"
        progressBar.destroy()
        delete progressBar

  paper.view.onFrame = (e) ->
    stats.begin()
    onFrameInstructions[onFrameAnimationState](e.delta) 
    stats.end()


  tool.onMouseMove = (e) ->
    for c in circles
      if !c.listenToMouseRepulsion()
        continue

      hitResult = c.circle.hitTest e.point,
        tolerance: 50
        fill: true
        stroke: true

      if hitResult && hitResult.item
        c.setMouseRepulsion e.point

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

    progressBar.adjustToSize(horizontalFactor, verticalFactor) if progressBar?

  $(window).scroll (e) ->
    for c in circles
      c.setScrollOffset $(window).scrollTop()



  window.stringifyAllLissajousPaths = ->
    j = '{"lissajousPaths": ['
    for c in circles
      j += c.exportLissajousPath()
      j += ","
    j = j.substring(0, j.length - 1)
    j += "]}"

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
