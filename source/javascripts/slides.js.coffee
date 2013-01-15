
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


