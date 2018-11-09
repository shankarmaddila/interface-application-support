namespace 'Data', (exports) ->
  exports.cleanColorName = (name)->
    thisFilterName = name.trim().toLowerCase().split(/[ .]+/)[0]
    thisFilterName = 'grey' if thisFilterName is 'gry'
    return thisFilterName

namespace 'Utility', (exports) ->
  exports.type = (obj) ->
    if obj == undefined or obj == null
      return String obj

    classToType = {
      '[object Boolean]': 'boolean',
      '[object Number]': 'number',
      '[object String]': 'string',
      '[object Function]': 'function',
      '[object Array]': 'array',
      '[object Date]': 'date',
      '[object RegExp]': 'regexp',
      '[object Object]': 'object'
    }

    return classToType[Object.prototype.toString.call(obj)]

  exports.stringToColour = (colorStr) ->
    a = document.createElement('div')
    a.style.color = colorStr
    colors = window.getComputedStyle(document.body.appendChild(a)).color.match(/\d+/g).map((a) ->
      parseInt a, 10
    )
    document.body.removeChild a
    if colors.length >= 3 then '#' + ((1 << 24) + (colors[0] << 16) + (colors[1] << 8) + colors[2]).toString(16).substr(1) else false

  exports.scrollTo = (targetEl, fixedEl) ->
    offset = $(targetEl).offset().top

    if fixedEl?
      offset = offset - $(fixedEl).height()

    $("html,body").animate
      scrollTop: offset
      , 1000

    return

namespace 'Eloqua', (exports) ->
  exports.eloquaLookup = (el) ->

    # eloqua looks for this function as a callback to elqDataLookup load
    window.SetElqContent = ->
      if @GetElqContentPersonalizationValue
        Vars.user.field_name_first =  GetElqContentPersonalizationValue("V_ElqFirstName")
        Vars.user.field_name_last = GetElqContentPersonalizationValue("V_ElqLastName")
        Vars.user.field_email = GetElqContentPersonalizationValue("V_ElqEmailAddress")
        Vars.user.field_company =  GetElqContentPersonalizationValue("V_ElqCompanyName")
        Vars.user.field_stateProv =  GetElqContentPersonalizationValue("V_State_or_Province1p")
        Vars.user.field_address1 =  GetElqContentPersonalizationValue("M_Address1")
        Vars.user.field_address2 =  GetElqContentPersonalizationValue("M_Address2")
        Vars.user.field_address3 =  GetElqContentPersonalizationValue("M_Address3")
        Vars.user.field_city =  GetElqContentPersonalizationValue("M_City")
        Vars.user.field_zipPostal =  GetElqContentPersonalizationValue("M_Zip_Postal")
        Vars.user.field_stateProv =  GetElqContentPersonalizationValue("V_State_or_Province1p")
        Vars.user.field_phone =  GetElqContentPersonalizationValue("V_Business_Phone1")
        Vars.user.field_account = GetElqContentPersonalizationValue("V_Account_Description1p")
        Vars.user.field_country = GetElqContentPersonalizationValue("V_CountryFromIP")

        # update promo banner
        if Vars.user.field_name_first.length > 0 or Vars.user.field_name_last.length > 0
          $(".promotion").find('.field-email').attr('value', Vars.user.field_email) if Vars.user.field_email?
          $(".dynamic-user").text(Vars.user.field_name_first) if Vars.user.field_name_first?
          $('.order-form .notice').removeClass('inactive')
          $('.log-in').addClass('inactive')

        else
          console.log "no user name in data"

      else
        console.log "could not request user data from Eloqua"

      return status

    # trigger eloqua to request the data lookup
    # console.log "_elqQ: ",_elqQ
    _elqQ.push [
      "elqDataLookup"
      escape("a191151afe8b4820a6319e0f5d30da64")
      ""
    ]

    return

  # eloqua loads in the head to properly scope the _elq variable. once its done it calls this function.
  exports.loadComplete = (elqCustomerGUID)->

    # assign the guid to the form element
    document.forms["eloquaData"].elements["elqCustomerGUID"].value = elqCustomerGUID

    # start data lookup now that we have the guid
    Eloqua.eloquaLookup()
    return

namespace 'AdobeS7', (exports) ->
  companyID = 'InterfaceInc'
  serverurl = 'http://s7d1.scene7.com/is/image/'
  videoserverurl = 'http://s7d1.scene7.com/is/content/'


  exports.loadVideo = (el)->
    # console.group("global.js: AdobeS7.loadVideo()")
    if !s7viewers?
      # console.error "Scene7 video js not found"
      return

    @asset = el.data('asset')

    buildVideo = ()=>
      @video = new (s7viewers.VideoViewer)(
        'containerId': el.attr('id')
        'params':
          'asset': companyID+'/'+@asset
          'serverurl': serverurl
          'videoserverurl': videoserverurl).init()
      return

    if el.hasClass('in-modal')
      modalID = el.closest('.reveal-modal').attr('id')
      $(document).on 'opened.fndtn.reveal', '#'+modalID+'[data-reveal]', ->

        @video = new (s7viewers.VideoViewer)(
          'containerId': el.attr('id')
          'params':
            'asset': companyID+'/'+el.data('asset')
            'serverurl': serverurl
            'videoserverurl': videoserverurl).init()

        return

    else
      buildVideo()

    # console.groupEnd()
    return

  exports.loadGallery = (el)->
    # console.group("global.js: AdobeS7.loadGallery() GO")

    if !s7viewers?
      console.error "Scene7 gallery js not found"
      return

    @asset = el.data('asset')

    buildGallery = ()=>
      @gallery = new (s7viewers.BasicZoomViewer)(
        'containerId': el.attr('id')

        'params':
          'asset': companyID+'/'+@asset
          'serverurl': serverurl
          'videoserverurl': videoserverurl
          'initialFrame': 2

        'handlers': 'initComplete': ->
          console.log 'Viewer initialized'
          return

        'localizedTexts':
          'en': 'CloseButton.TOOLTIP': 'Close'
          'fr': 'CloseButton.TOOLTIP': 'Fermer'
          defaultLocale: 'en')

      # console.log @gallery

      @gallery.init()
      console.log @gallery

      return

    if el.hasClass('in-modal')
      modalID = el.closest('.reveal-modal').attr('id')

      $(document).on 'opened.fndtn.reveal', '#'+modalID+'[data-reveal]', ->

        @gallery = new (s7viewers.MixedMediaViewer)(
          'containerId': el.attr('id')
          'params':
            'asset': companyID+'/'+el.data('asset')
            'serverurl': serverurl
            'videoserverurl': videoserverurl).init()

        return

    else
      buildGallery()

    # console.groupEnd()
    return
