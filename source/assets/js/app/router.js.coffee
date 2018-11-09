App.structure.router = Backbone.Router.extend
  routes:
    'ref=:refferal': 'welcome'
    'source=:dataSource': 'start'
    '': 'start'

  activeViews: {}
  filteredColors: false
  requestedView: null
  appStart: false
  safeMode: false
  dataSource: null
  missedPartNumbers: null
  revisionSource: null
  admin: false
  currentDataHistory: null
  customColorCollection: null
  adminControlsReady: false

  initialize: ()->
    # console.group "router initialize"

    @admin = true if $('body').hasClass('admin')

    if not Backbone.History.started
      # console.log "new history"
      Backbone.history.start()

    else
      # console.log "already history"
      location.reload()

    # console.groupEnd()
    @

  welcome: (refferal)->

    if refferal is 'rs'
      $('#modal_welcomeRadstock').foundation 'reveal', 'open'

    @start()

    @

  start: (dataSource)->
    # console.log "start"
    @fbSourceURL = "https://interfacespecials.firebaseio.com/"

    if @admin
      @dataSource = dataSource or "qa"

    else
      @dataSource = dataSource or "production"

    console.log @dataSource

    @fbSetup()

    return @

  setFBSettings: (newSettings)->
    if @dataSource is 'qa'
      window.SpecialsFirebase_settingsRef.child('settings').child('source_qa').set(newSettings)

    else if @dataSource is 'production'
      window.SpecialsFirebase_settingsRef.child('settings').child('source_production').set(newSettings)

    else
      console.error "setFBSettings failed, no datasource specified"

    return

  fbSetup: ()->
    webjobVersionURL = ""

    # 1. Load the data source
    window.SpecialsFirebase_settingsRef = new Firebase(@fbSourceURL)

    # if @dataSource is 'qa'
    #   dataHistorySource = 'qa'
    # else if @dataSource is 'production'
    #   dataHistorySource = 'prod'
    # else
    #   dataHistorySource = 'qa'

    # get the app setting that determines which history version to load
    window.SpecialsFirebase_settingsRef.child('settings').on 'value', (settings) =>
      @currentDataHistory = settings.val()

      # 2. Get the active version url of product data
      if @dataSource is 'qa'
        webjobVersionURL = "products/"+@currentDataHistory.source_qa

      else if @dataSource is 'production'
        webjobVersionURL = "products/"+@currentDataHistory.source_production

      else
        console.error "no data source defined: "+@dataSource


      productDataURL = @fbSourceURL+webjobVersionURL+"/imageInfo/"


      @getFBData(productDataURL)
      @renderMissedPartNumbers(webjobVersionURL)

      console.log "getting data from ",productDataURL

      return

    # populate the data history select
    if @admin
      # console.log "populate the data history select..."
      @renderAdminVersionSelect()

    return @

  getFBData: (productDataURL)->
    # console.log "getFBData"
    # console.log "productDataURL: ",productDataURL

    SpecialsFirebaseCollection = Backbone.Firebase.Collection.extend(
      model: App.structure.model
      url: productDataURL
      autoSync: false)

    specialsFirebaseData = new SpecialsFirebaseCollection

    specialsFirebaseData.on 'sync', (data) =>
      # console.log "products sync!"
      App.data.products = data

      # get the custom color data and assign to products
      @getCustomColors(productDataURL)
      return

    # one way fetch of data from Firebase
    specialsFirebaseData.fetch()

    return @

  getCustomColors: (action)->
    FBCollection_customColor = Backbone.Firebase.Collection.extend(
      model: App.structure.model.customColor
      url: "https://interfacespecials.firebaseio.com/customColorFamily"
      autoSync: false)

    @customColorCollection = new FBCollection_customColor

    @customColorCollection.on 'sync', (collection) =>
      # console.log "custom color sync!"
      App.data.customColors = collection

      if action is 'refresh'
        # create color family backbone collection
        @processColorFilter(action)

      else
        @fbDataComplete()

      return

    # one way fetch of data from Firebase
    @customColorCollection.fetch()

    return

  fbDataComplete: ()->
    # create color family backbone collection
    @processColorFilter()

    # start the app
    @appViewStart()

    return @

  appViewStart: ()->
    if @appStart is false
      App.live.activeViews.app = new App.structure.view.app()
      @appStart = true

    else
      # console.log "just render"
      App.live.activeViews.app.refresh()
      App.live.activeViews.app.render()

    return @

  renderMissedPartNumbers: (webjobVersionURL)->
    return if !@admin

    window.SpecialsFirebase_settingsRef.child("/"+webjobVersionURL+"/missedPartNumbers/").on 'value', (data) =>
      @missedPartNumbers = data.val()

      $productErrors = $('.product-errors')
      $logEl = $('.missed-log').empty()

      if @missedPartNumbers? and @missedPartNumbers.length > 1
        $logEl.addClass('active')
        $productErrors.addClass('active')

        # setup email vars
        $emailEl = $productErrors.find('.control-email')
        emailAddress = "graeme.ripley@interface.com"
        emailSubject = "Missing Specials Products"
        emailHref = "mailto:"+emailAddress+"?subject="+encodeURI(emailSubject)+"&body="
        emailBody = ""

        _.each @missedPartNumbers, (number, key, list)->
          $logEl.prepend("<div class='entry'><span class='m'>"+number+"</span></div>")
          emailBody += number+"%0D%0A"


        $productErrors.find('.count').text(@missedPartNumbers.length)

      else
        $logEl.removeClass('active')
        $productErrors.removeClass('active')

      emailHref += emailBody

      $emailEl.attr('href', emailHref)

      return

    return

  renderAdminVersionSelect: ()->
    window.SpecialsFirebase_settingsRef.child('products').on 'value', (data) =>
      App.data.productHistory = data.val()

      maxHistoryItems = 20

      $dataSelect = $('#dataSourceSelect').empty().append('<option disabled="disabled">Select a Revision</option>')

      # what is the current active QA version?
      activeVersionID = @currentDataHistory.source_qa

      # if @dataSource is 'qa'
      #   activeVersionID = @currentDataHistory.source_qa
      # else if @dataSource is 'production'
      #   activeVersionID = @currentDataHistory.source_production

      # create each option for each version
      # if that version is the active version make it the selected option

      dateOptions = {
        year: 'numeric'
        month: 'short'
        day: 'numeric'
        hour: 'numeric'
        minute: 'numeric'
      }

      $.each _.keys(App.data.productHistory).reverse(), (key, versionID) ->

        # only display a certain number of history entires
        if parseInt(key) is parseInt(maxHistoryItems - 1)
          return false

        thisDate = new Date(parseInt(versionID))

        if versionID is activeVersionID
          option = new Option(thisDate.toLocaleDateString("en-US", dateOptions), versionID, true, true)

        else
          option = new Option(thisDate.toLocaleDateString("en-US", dateOptions), versionID, false, false)

        $dataSelect.append(option)
        return

      if @adminControlsReady is false
        console.log "bind controls"

        $dataSelect.change (e) =>
          newOption = $dataSelect.find("option:selected").val()
          @setFBSettings(newOption)
          return

        $('#publishProduction').click (e) =>
          e.preventDefault()
          newVal = $dataSelect.find("option:selected").val()
          console.group("publishing production")

          if confirm("Set Production to version "+newVal+"?")
            window.SpecialsFirebase_settingsRef.child('settings').child('source_production').set(newVal)
            $('.productionVersion').text(new Date(parseInt(newVal)))

          console.groupEnd()
          return

      # update the active production version number
      @renderAdminActiveProductionVersion()

      @adminControlsReady = true
      return

    @

  renderAdminActiveProductionVersion: ()->
    window.SpecialsFirebase_settingsRef.child('settings').child('source_production').on 'value', (data) =>
      $('.productionVersion').text(new Date(parseInt(data.val())))
      return
    return

  processColorFilter: (action)->
    # create a collection of unuiqe colors
    App.data.colorFamilies = new App.structure.collection.color()

    allColors = []
    filteredAllColors = []

    _.each App.data.products.models, (model, key, list) ->

      thisID = model.get('id')
      thisColorObj = _.keys(model.get('colorFamily'))

      # create a new custom color entry in Firebase if we have a new product
      if App.data.customColors.where({id : thisID}).length < 1
        window.SpecialsFirebase_settingsRef.child('customColorFamily').child(thisID).set({'id':thisID})

      # if this product has colors add it to the master list
      allColors.push(thisColorObj) if not _.isEmpty(thisColorObj)

    filteredAllColors = _.uniq(_.flatten(allColors))

    # console.group("Unique Color Families")
    # console.log filteredAllColors
    # console.groupEnd()

    _.each filteredAllColors, (colorFamilyName, key, list)->

      colorModelStructure = {
        colorFamilyName: colorFamilyName
      }

      newColorFamModel = new App.structure.model.color(colorModelStructure)

      App.data.colorFamilies.add(newColorFamModel)

    App.live.activeViews.app.loadColorFilter() if action is 'refresh'
    return @

