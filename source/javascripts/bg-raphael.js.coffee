class LissajousCircle
  constructor: (@paper, radius, color, @wx, @wy, @omega, @t = 0, @speed = 0.001) ->

    #calculate lissajous path
    path_string = "M"
    for num in [0...2*Math.PI] by 0.01
      path_string += (Math.sin(@wx*num+@omega) + 1) * @paper.width / 2 + "," + (Math.sin(@wy*num+@omega) + 1) * @paper.height / 2
      if num == -1
        path_string += "L"
      else
        path_string += " "
    path_string += "z"

    @path = @paper.path path_string

    @circle = @paper.circle(0, 0, radius).attr 
      fill: color
      stroke: color
      "fill-opacity": 0.5
      "stroke-width": 0
      animationPath: @path
      alongAnimationPath: 0

    ###@glow = @circle.glow
      color: color
      opacity: 0.5
      fill: color###

    @circle.animate
      alongAnimationPath: 1
    , 2e5


  progress: ->
    @t += @speed

  lissajous: ->
    return r =
      x: Math.sin(@wx*@t+@omega)
      y: Math.sin(@wy*@t+@omega)

  ###move: ->
    console.log this
    r = @lissajous()
    @progress()

    r.x = (r.x + 1) * @paper.width / 2
    r.y = (r.y + 1) * @paper.height / 2

    @circle.stop().animate
      cx: r.x
      cy: r.y
    , 100

    #@glow.transform "t#{r.x},#{r.y}"###



animateLissajousCircles = (circles) ->
  c.move() for c in circles

  window.setTimeout ->
    animateLissajousCircles(circles)
  , 1

$ ->
  bg = $('#bg-raphael')
  bg.css
    width: $(window).width()/2
    height: $(window).height()

  paper = Raphael(bg[0], $(window).width()/2, $(window).height())
  paper.customAttributes.animationPath = ->
  paper.customAttributes.alongAnimationPath = (v) ->
    path = this.attrs.animationPath
    point = path.getPointAtLength(v * path.getTotalLength())
    return r =
      transform: "t" + [point.x, point.y] + "r" + point.alpha

  circles = [
    new LissajousCircle(paper, 200, "#00AAFF", 3, 1, 1/2 * Math.PI),
    new LissajousCircle(paper, 400, "#AAFF00", 4, 3, 1/3 * 1/4 * Math.PI),
    new LissajousCircle(paper, 200, "#FFAA00", 1, 4, 1/2 * 1/3 * Math.PI),
    new LissajousCircle(paper, 300, "#AA00FF", 3, 4, 1/3 * 3/4 * Math.PI),
    new LissajousCircle(paper, 100, "#FF00AA", 2, 1, Math.PI)
  ]
  ###
  circles = [
    new LissajousCircle(paper, 100, "#FF00AA", 2, 1, Math.PI)
  ]###

  #animateLissajousCircles(circles)


