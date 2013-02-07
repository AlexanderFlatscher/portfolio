
$ ->
  

  nav = $('nav')
  icon = nav.children('.menu_icon').first()
  html = $('html')

  adjustMargin = ->
    nav.css 
      marginRight: Math.max(($(window).width() - $('#wrapper').width())/2, 0)

  adjustMargin()

  icon.click (e) ->
    return false

  ###icon.bind
    touchstart: ->
      console.log "touchstart"
      icon.css
        background: 'red'
    touchend: ->
      console.log "touchend"
      icon.css
        background: 'blue'
    touchleave: ->
      console.log "touchleave"
      icon.css
        background: 'green'
    touchcancel: ->
      console.log "touchcancel"
      icon.css
        background: 'yellow'###

  if html.hasClass 'touch'
    icon.bind "click", (e) ->
      console.log "click"
      if html.hasClass 'nav_open' then html.removeClass 'nav_open' else html.addClass 'nav_open'
      #return false

  else
    nav.hover (e) ->
      html.addClass 'nav_open'
    , (e) ->
      html.removeClass 'nav_open'

  $(window).resize adjustMargin
  ###$(window).load ->
    if window.location.hash
      $.scrollTo window.location.hash, 500###

  links = $('ul li a', nav)
  links.click (e) ->
    hash = $(e.target).attr('href')
    $.scrollTo hash, 500
      onAfter: ->
        window.location.hash = hash

    return false

  ###$('#wrapper').bind 'sectionChange', ->
    $('#nav_bg').css
      backgroundColor: "hsl(#{(app.backgroundHue + 360 - 0) % 360 }, 100%, 10%)"###