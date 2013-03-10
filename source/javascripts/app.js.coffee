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
  slides = $('.slide')
  firstSlide = slides.first()

  window.app =

    activeSlide: firstSlide

    activateSlideWithId: (id) ->
      s = $("##{id}")
      if s
        app.activeSlide = s
        app.applyBackgroundHue(parseFloat(s.attr('data-background-hue')))
        $(window).trigger $.Event('sectionChange', {hue: app.backgroundHue, index: slides.index(s)})
      else
        return false

    backgroundHue: parseFloat(firstSlide.attr('data-background-hue'))

    applyBackgroundHue: (hue) ->
      app.backgroundHue = hue

