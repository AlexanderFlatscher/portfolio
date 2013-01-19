
$ ->
  nav = $('nav')

  adjustMargin = ->
    nav.css 
      marginRight: Math.max(($(window).width() - $('#wrapper').width())/2, 0)

  adjustMargin()
      
  nav.removeClass('open')
  nav.hover (e) ->
    nav.addClass 'open'
  , (e) ->
    nav.removeClass 'open'

  $(window).resize adjustMargin

  links = $('ul li a', nav)
  links.click (e) ->
    hash = $(e.target).attr('href')
    $.scrollTo hash, 500
      onAfter: ->
        window.location.hash = hash

    return false