$ ->
  nav = $('nav')
  icon = nav.children('.menu_icon').first()
  html = $('html')

  adjustMargin = ->
    if $(window).width() >= 600
      nav.css 
        marginRight: Math.max(($(window).width() - $('#wrapper').width())/2, 0)

  adjustMargin()

  icon.click (e) ->
    return false

  if html.hasClass 'touch'
    icon.bind "click", (e) ->
      if html.hasClass 'nav_open' then html.removeClass 'nav_open' else html.addClass 'nav_open'
      return false

  else
    nav.hover (e) ->
      html.addClass 'nav_open'
    , (e) ->
      html.removeClass 'nav_open'

  $(window).resize adjustMargin

  links = $('ul li a', nav)
  links.click (e) ->
    hash = $(e.target).attr('href')
    $.scrollTo hash, 500
      onAfter: ->
        window.location.hash = hash
    return false
