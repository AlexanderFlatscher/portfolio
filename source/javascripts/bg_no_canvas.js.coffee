return if Modernizr.canvas

$ ->
  scroll_factors = 
    biggest: 0.2
    big: 0.4
    medium: 0.5
    small: 0.6
    smallest: 0.9

  bg_no_canvas = $('#bg_no_canvas')
  window.bg_circles = bg_no_canvas.find('.bg_circle')

  if Modernizr.csstransitions
    bg_circles.not(".bg_circle0").addClass 'inactive'
  else
    bg_circles.not(".bg_circle0").css
      display: 'none'

  $(window).scroll ->
    scrollTop = $(window).scrollTop()

    for name, factor of scroll_factors
      bg_no_canvas.children(".#{name}").css
        top: - parseInt(scrollTop) * factor

  $(window).bind 'sectionChange', (e) ->
    actives = bg_circles.filter(".bg_circle#{e.index}")
    inactives = bg_circles.not(".bg_circle#{e.index}")
    if Modernizr.csstransitions
      actives.removeClass 'inactive'
      inactives.addClass 'inactive'
    else if Modernizr.opacity
      actives.finish().fadeIn(1000)
      inactives.stop().fadeOut(1000)
    else
      actives.css 'display', 'block'
      inactives.css 'display', 'none'




