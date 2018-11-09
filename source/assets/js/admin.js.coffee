#= require dropzone/dist/min/dropzone.min.js
#= require select2/dist/js/select2.full.min.js

# dev info
# -------
# webjob log:   https://interface-specials-framework.scm.azurewebsites.net/azurejobs/#/jobs/triggered/publish
# local file upload url: localhost:5000/upload

statusURL = "http://interface-specials-framework.azurewebsites.net/api/publish/history"

# publish url
publishURL = 'http://interface-specials-framework.azurewebsites.net/api/publish'

# the button the user clicked on
window.dataRequestType = null

# file upload url
uploadURL = {
  local: 'localhost:5000/upload'
  production: '/upload'
}

status = {
  production: null
  qa: null
}

log = []

$logEL = $('.log')
$overlayEL = $('.activity-overlay')
$controlButtons = $('.controls button')
$dataRevisionParent = $('#panel_qa')
pingDelay = 1000


getTime=()->
  return new Date().toLocaleTimeString()

doneFail=(moment, status)->
  log.push({t:moment,m:status})
  renderLog('fail')

  toggleUI('show')
  toggleErrors('show')
  window.onbeforeunload = null
  return

doneSuccess=(moment, status)->
  log.push({t:moment,m:status})
  renderLog('success')

  toggleUI('show')
  toggleErrors('show')
  window.onbeforeunload = null

  # $('#adminFileResult .message').text("New file uploaded.")
  # $('#adminFileResult').foundation('reveal', 'open')

  App.live.renderAdminVersionSelect()
  App.live.activeViews.app.render()

  # location.reload()
  return

toggleLog=(view)->
  if view is 'show'
    $('.data-status').fadeIn()
    $('.product-errors').fadeOut()
    $logEL.addClass('active')

  else if view is 'hide'
    $('.data-status').fadeOut()
    $logEL.removeClass('active')

  else
    console.error "specify a view for toggleLog"

  return

toggleErrors=(view)->
  if view is 'show'
    $('.product-errors').fadeIn()
  else if view is 'hide'
    $('.product-errors').fadeOut()
  else
    console.error "specify a view for toggleErrors"
  return

toggleUI=(view)->

  if view is 'show'
    $overlayEL.removeClass('active')
    $overlayEL.css('width', 'auto')
    $('.admin-controls').removeClass('disable')
    $('.product-offers').removeClass('disable')

  else if view is 'hide'
    $('.admin-controls').addClass('disable')
    $overlayEL.css('width', $overlayEL.width()+'px')
    $overlayEL.addClass('active')
    $('.product-offers').css('min-height', '100%').addClass('disable')

  else
    console.error "specify a view for toggleErrors"
  return


renderLog=(eventClass)->
  $logEL.empty()
  _.each log, (obj, key, list)->

    if obj.m is 'Running'
      statusLabel = 'secondary'

    else if obj.m is 'Initializing'
      statusLabel = 'warning'

    else if obj.m is 'Success'
      statusLabel = 'success'

    else if obj.m is 'Failed' or obj.m is 'Aborted' or obj.m is null or obj.m is 'Upload Error' or obj.m is 'Upload Canceled'
      statusLabel = 'alert'

    else
      statusLabel = 'secondary'

    @template = "<div class='entry "+eventClass+"'><span class='t'>"+obj.t+"</span><span class='m label "+statusLabel+" '>"+obj.m+"</span></div>"

    $logEL.prepend(@template)
  return

renderStatus=()->
  # set this status based on the user's data request
  @thisStatus = status.latest_run.status or ''
  @moment = new Date().toLocaleTimeString()

  if @thisStatus is 'Success'
    doneSuccess(@moment, @thisStatus)

  else if @thisStatus is 'Running' or @thisStatus is "Initializing"
    log.push({t:@moment,m:@thisStatus})
    renderLog()
    _.delay ->
      window.pingStatus(@thisStatus)
    , pingDelay

  else if @thisStatus is 'Failed' or @thisStatus is "Aborted"
    doneFail(@moment, @thisStatus)

  else
    doneFail(@moment, @thisStatus)

  return

renderGenericLog=(message)->
  @moment = new Date().toLocaleTimeString()

  log.push({t:@moment, m:message})

  renderLog()
  return

sortData=(data)->
  status = data[0]
  # status.qa = _.where(data, {name: "publish-qa"})[0]
  return

navigationWarning=()->

  # If we haven't been passed the event get the window.event
  e = e or window.event

  message = 'A file upload is in progress. Leaving this page will abort the file upload.'

  # For IE6-8 and Firefox prior to version 4
  if e
    e.returnValue = message

  # For Chrome, Safari, IE8+ and Opera 12+

  return message

window.pingStatus=()->
  $.getJSON(statusURL).done((data) ->
    sortData(data)
    renderStatus()
    return

  ).fail (jqxhr, textStatus, error) ->
    err = textStatus + ', ' + error
    console.log 'pingStatus failed: ' + err
    renderGenericLog('Status Failed: ' + err)
    return
  return

startNewStatusPing=(method)->
  # show ui
  toggleLog('show')
  toggleUI('hide')

  $logEL.prepend("<div class='entry'><span class='t'>"+getTime()+"</span><span class='m'>Starting Up...</span></div>")

  if method is 'manual'
    $.ajax
      url: publishURL
      type: 'get'

      success: (data) ->
        console.log "manual webjob trigger"
        window.pingStatus()
        return

      error: (e) ->
        console.log "manual webjob trigger failed"
        console.log 'error: ' + e
        doneFail(getTime(), 'Webjob Failed')
        return

  else if method is 'upload'
    console.log "upload webjob trigger"
    window.pingStatus()

  else
    console.log "no method specified - no action..."

  return

urlFunction = (data) ->
  window.dataRequestType = 'qa'
  uploadURL = uploadURL.production
  console.log 'uploadURL: ',uploadURL
  return uploadURL

Dropzone.options.csvUpload =
  url: urlFunction
  method: "post"
  paramName: 'file'
  uploadMultiple: false,
  acceptedFiles: '.csv'
  previewsContainer: '#uploadPreview'
  init: ->
    @on 'addedfile', (file) ->
      # 1
      console.log "dz: file added"
      console.log file

      return

    @on 'sending', (file) ->
      # 2
      console.log "dz: sending"

      # Turn it on - assign the function that returns the string
      window.onbeforeunload = navigationWarning

      toggleLog('show')
      toggleUI('hide')
      renderGenericLog('File Sending')
      return

    @on 'success', (file) ->
      # 3
      console.log "dz: success"
      renderGenericLog('File Upload Success')
      startNewStatusPing('upload')
      return

    @on 'complete', (file) ->
      # 4
      console.log "dz: complete"
      return

    @on 'error', (file) ->
      console.log "dz: error ",file
      doneFail(getTime(), 'Upload Error')
      return

    @on 'processing ', (file) ->
      console.log "dz: processing"
      renderGenericLog('File Processing')
      return

    @on 'uploadprogress ', (file) ->
      console.log "dz: uploadprogress"
      return

    @on 'canceled', (file) ->
      console.log "dz: canceled ",file
      doneFail(getTime(), 'Upload Canceled')
      return


    $('.dz-default.dz-message').empty().append($('#uploadPreview').html())
    return

$('.trigger-qa').click (e) ->
  window.dataRequestType = 'qa'
  # $controlButtons.attr('disabled', 'disabled')
  startNewStatusPing('manual')
  return false

$toolbar = $('.toolbar')
$overlayEl = $('.activity-overlay')
$productEl = $('.layout-product')
setToolbar = false


$overlayEl.css('max-width', $productEl.width()+'px')
$('#productFilter').css('max-width', $('.product-offers > .content').width()+'px')

$(window).resize _.debounce((->
  $overlayEl.css('max-width', $productEl.width()+'px')
  $('#productFilter').css('max-width', $('.product-offers > .content').width()+'px')
  return
), 500)

window.topbarUnFixed = () ->
  return if $('body').hasClass('preview-active')
  $toolbar.removeAttr('style')
  return

window.topbarFixed = () ->
  return if $('body').hasClass('preview-active')

  $toolbar.css({
    width:  $('.activity-overlay').width()+'px'
    right: 0
    left: 'initial'
  })
  return

$('.post-file-action').click (e) ->
  e.preventDefault()
  location.reload()
  return

$('.preview-trigger').click (e) ->
  $('html').animate {opacity: '0'},
    queue: false
    duration: 500
    complete: ->

      # a bunch of layout changes happen here in css
      $('body').toggleClass('preview-active')

      _.delay ->
        $(document).foundation('topbar', 'reflow')
        $(document).foundation('equalizer', 'reflow')
        $('.product-grid').toggleClass('view-config view-scene')
        $('#productFilter').css('max-width', $('.product-offers > .content').width()+'px')

        # close any active filters
        $('.color-tile-view-close').trigger('click')

        $('html').animate opacity: '1'
      , 500
      return

  return
