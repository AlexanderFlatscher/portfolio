
$ ->
  nav = $('nav')
  icon = nav.children('.menu_icon').first()

  adjustMargin = ->
    nav.css 
      marginRight: Math.max(($(window).width() - $('#wrapper').width())/2, 0)

  adjustMargin()

  if $('body').hasClass 'touch'
    icon.click (e) ->
      if nav.hasClass 'open' then nav.removeClass 'open' else nav.addClass 'open'

  else
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

  $('#wrapper').bind 'sectionChange', ->
    $('#nav_bg').css
      backgroundColor: "hsl(#{(app.backgroundHue + 360 - 0) % 360 }, 100%, 10%)"