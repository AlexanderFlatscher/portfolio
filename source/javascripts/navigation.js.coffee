$ ->
  nav = $('nav')
  nav.removeClass('open')

  

  nav.hover (e) ->
    nav.addClass 'open'
  , (e) ->
    nav.removeClass 'open'