
$ ->
  slides = $('#wrapper .slide')
  w = $(window)

  centerSlides = () ->
    slides.each (i, e) ->
      element = $(e)
      eh = element.height()
      wh = w.height()
      padding = if eh < wh then (wh - eh)/2 else ''

      element.css
        paddingTop: padding
        paddingBottom: padding

  w.load centerSlides
  w.resize centerSlides

  w.scroll (e) ->
    breakpoint = w.scrollTop() + w.height()/2
    lastTop = -1 
    nearestSlideId = undefined

    for slide in slides
      s = $(slide)
      top = s.position().top
      if top > lastTop and top < breakpoint
        lastTop = top
        nearestSlideId = s.attr('id')
        
    app.activateSlideWithId(nearestSlideId) if app.activeSlide.attr('id') != nearestSlideId




