$ ->
  firstSlide = $('.slide').first()

  window.app =

    activeSlide: firstSlide

    activateSlideWithId: (id) ->
      console.log "activateSlideWithId #{id}"
      s = $("##{id}")
      if s
        app.activeSlide = s
        app.applyBackgroundHue(s.attr('data-background-hue'))
      else
        return false

    backgroundHue: firstSlide.attr('data-background-hue')

    applyBackgroundHue: (hue) ->
      console.log "applyBackgroundHue #{hue}"
      app.backgroundHue = hue
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