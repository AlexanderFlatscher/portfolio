
$ ->
  slides = $('#wrapper .slide')
  w = $(window)

  centerSlides = () ->
    if wh = w.height() >= 1382 
      slides.each (i, e) ->
        element = $(e)
        eh = element.height()
        padding = if eh < wh then (wh - eh)/2 else ''

        element.css
          paddingTop: padding
          paddingBottom: padding
    else
      slides.each (i, e) ->
        $(e).css
          paddingTop: 0
          paddingBottom: 0

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




