
$ ->
  slides = $('#wrapper .slide')
  w = $(window)

  centerSlides = () ->
    wh = w.height()
    ww = w.width()
    if ww > wh and ww >= 600#1382 
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
          paddingTop: ''
          paddingBottom: ''

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




