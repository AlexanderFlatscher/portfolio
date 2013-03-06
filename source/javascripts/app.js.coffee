Modernizr.load
  load: '/javascripts/hyphenator.js', 
,
  test: Modernizr.touch
  yep: "/javascripts/fastclick.min.js"
  callback: (result, key) ->
    if result
      $ ->
        $('.fastclick').each ->
          console.log "fastclick"
          new FastClick(this)
,
  test: Modernizr.mq('only all')
  nope: "javascripts/respond.min.js"
###,
  test: Modernizr.canvas
  yep: "/javascripts/paper.js"###


$ ->
  firstSlide = $('.slide').first()

  window.app =

    activeSlide: firstSlide

    activateSlideWithId: (id) ->
      s = $("##{id}")
      if s
        app.activeSlide = s
        app.applyBackgroundHue(parseFloat(s.attr('data-background-hue')))
        $('#wrapper').trigger 'sectionChange'
      else
        return false

    backgroundHue: parseFloat(firstSlide.attr('data-background-hue'))

    applyBackgroundHue: (hue) ->
      app.backgroundHue = hue
      $(window).trigger $.Event('backgroundHueChange', {hue: hue})
      #app.colorAnimation.current = 0

    ###colorAnimation:
      current: 0
      end: 50
      isRunning: () ->
        return app.colorAnimation.current < app.colorAnimation.end
      isFirstStep: () ->
        return app.colorAnimation.current == 0
      isLastStep: () ->
        return app.colorAnimation.current == (app.colorAnimation.end - 1)###