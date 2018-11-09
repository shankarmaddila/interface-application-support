###
Requires
###

#= require jquery/dist/jquery.min.js

#= require underscore/underscore-min.js
#= require underscore-query/lib/underscore-query.min.js
#= require backbone/backbone-min.js
#= require backbone-filtered-collection/backbone-filtered-collection
#= require firebase/firebase.js
#= require backbonefire/dist/backbonefire.min.js
#= require jquery.cookie/jquery.cookie.js
#= require imagesloaded/imagesloaded.pkgd.min.js
#= require slick-carousel/slick/slick.js
#= require foundation/js/foundation.js
#= require _namespace-init
#= require _global
#= require_directory ./app

# if typeof (window.console.log) is "undefined"
#   console.log = console.error = console.info = console.debug = console.warn = console.trace = console.dir = console.dirxml = console.group = console.groupEnd = console.time = console.timeEnd = console.assert = console.profile = ->

window.allColors = []

window.appReady = ()->
  $('body').removeClass('preload')
  $('#signIn').foundation('reveal', 'close')

  return

$(document).ready ->

  IE8.foundationFix() if $('html').hasClass('lt-ie9')

  isiPad = navigator.userAgent.match(/iPad/i) != null
  if isiPad
    $('html').addClass('ipad')

  $(document).foundation()

  # start up
  if $('body').hasClass('admin')
    # $('#adminLoading').foundation('reveal', 'open')
    authRef = new Firebase('https://interfacespecials.firebaseio.com')

    authDataCallback = (data) ->
      if data is null
        console.log "no data ",data
        $('#signIn').foundation('reveal', 'open')

      else
        # console.log "data back: ",data
        $('.auth-user').text(data.password.email)
        App.live = new App.structure.router()
      return

    newAuthRequest = ($thisForm) ->
      authRef.authWithPassword {
        email: $thisForm.find('.email').val()
        password: $thisForm.find('.key').val()
      }, (error, data) ->
        if error
          console.log 'Login Failed!', error

          $.when($('.auth-loading').fadeOut('fast')).then () ->
            $('#formMessage').show().text("Invalid Login")

        else
          console.log 'Authenticated successfully with payload:', data
        return

      return

    $('#signInForm').on("invalid.fndtn.abide", ->
      console.log "login form error"
    ).on "valid.fndtn.abide", ->
      $('#formMessage').hide()
      $('.auth-loading').fadeIn()
      newAuthRequest($(@))

    $.when(authRef).done (x) ->
      authRef.onAuth(authDataCallback)

    $('#signOut').click (e) ->
      e.preventDefault()
      $('body').addClass('preload')
      authRef.unauth()
      return

  else

    $('#productFilter').css('max-width', $('.product-offers > .content').width()+'px')

    $(window).resize _.debounce((->
      $('#productFilter').css('max-width', $('.product-offers > .content').width()+'px')
      return
    ), 500)

    window.topbarUnFixed = ()->
      false
    window.topbarFixed = ()->
      false

    App.live = new App.structure.router()

  $('.nav-item.center-headline').click (e) ->
    Utility.scrollTo($('#productGridTop'), $('.section-subnav.top-bar'))
    false

  $('.welcome-close').click (e) ->
    e.preventDefault()
    $('#modal_welcomeRadstock').foundation('reveal', 'close')
    false

  return


  return
