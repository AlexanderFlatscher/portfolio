
$ ->
  nav = $('nav')

  adjustMargin = () ->
    nav.css 
      marginRight: $('#wrapper').css('margin-right')

  adjustMargin()
      
  nav.removeClass('open')
  nav.hover (e) ->
    nav.addClass 'open'
  , (e) ->
    nav.removeClass 'open'

  $(window).resize adjustMargin