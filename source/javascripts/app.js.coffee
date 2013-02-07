Modernizr.load
  test: Modernizr.touch
  yep: "/javascripts/fastclick.min.js"
  callback: (result, key) ->
    if result
      console.log "fastclick loaded"
      $ ->
        $('.fastclick').each ->
          console.log "fastclick"
          new FastClick(this)
    else
      console.log "no touch"


$ ->
  firstSlide = $('.slide').first()

  window.app =

    activeSlide: firstSlide

    activateSlideWithId: (id) ->
      s = $("##{id}")
      if s
        app.activeSlide = s
        app.applyBackgroundHue(s.attr('data-background-hue'))
        $('#wrapper').trigger 'sectionChange'
      else
        return false

    backgroundHue: parseFloat(firstSlide.attr('data-background-hue'))

    applyBackgroundHue: (hue) ->
      app.backgroundHue = parseFloat(hue)
      app.colorAnimation.current = 0

    colorAnimation:
      current: 0
      end: 50
      isRunning: () ->
        return app.colorAnimation.current < app.colorAnimation.end
      isFirstStep: () ->
        return app.colorAnimation.current == 0
      isLastStep: () ->
        return app.colorAnimation.current == (app.colorAnimation.end - 1)