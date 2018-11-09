
# string filter polyfill
if !String::contains
  String::contains = ->
    String::indexOf.apply(this, arguments) != -1

class App.structure.view.app extends Backbone.View
  el: $('body')

  events:
    "click .filter-toggle": "toggleColorFilter"

  tileViews: []
  colorViews: []
  customColorViews: []
  activeProduct: null

  activeFilterColor: false
  filterResultsColor: []
  colorFilterSet: []

  activeFilterSearch: false
  filterResultsSearch: []
  searchFilterSet: []

  filterWarranty: ''
  filterWarrantySaveData: []

  filteredCollectionActive: false

  tabRequestFromTile: 'request'
  slideBuildProduct: null
  gridProductCount: 0
  gridStyleRender: false
  customColorCollection: null


  initialize: (options)->
    @productCollection = App.data.products
    @productCollectionFiltered = new FilteredCollection(@productCollection)

    @$productGridParentEl = $('.product-offers')
    @containerProductIndex = $('ul.product-grid')
    @$modalProduct = $('#modal_productInterstitial')
    @$modalLoader = $('#modal_productInterstitial .loader')
    @render()

    @loadColorFilter()

    # these only happen once
    @initializeCompontentTab()
    @initializeCompontentModal()
    @initializeColorControls()
    @initializeProductForm()
    @initializeSubscriptionForm()
    @initializeCompontentToolbar()
    # @initializeCustomColors()





    @



  refresh: ()->
    @productCollection = App.data.products
    return @

  # ui components
  initializeCompontentTab:()->

    $('#modalTabs').on 'toggled', (event, tab) =>
      requestedTab = tab.context.hash

      # render the content based on request
      if requestedTab is '#panel_order'
        @buildTabOrder()

        # match panel heights
        # $('.order-aside .panel').css('min-height', $('.order-primary .panel').css('height'))


      else if requestedTab is '#panel_detail'
        @buildTabDetail()

      else if requestedTab is '#panel_download'
        @buildTabDownload()

      else
        console.log "No action specified. @tabRequestFromTile: ",@tabRequestFromTile

      return

    return

  initializeCompontentModal:()->
    currentOrder = @tabRequestFromTile

    $(document).on 'open.fndtn.reveal', '#modal_productInterstitial[data-reveal]', =>
      # build modal header
      modalHeaderTemplate = _.template($("#modal_header").html())
      headerVars = @activeProduct.attributes


      if @activeProduct.attributes.product.name is 'Custom'
        headerVars.showColorMeta = "hide"
      else
        headerVars.showColorMeta = "show"

      modalHeaderMarkup = modalHeaderTemplate(headerVars)
      $('.modal-header .product-data').empty().append(modalHeaderMarkup)
      return

    # after the model opens
    $(document).on 'opened.fndtn.reveal', '#modal_productInterstitial[data-reveal]', ->
      # console.log "model opened"
      $('html').addClass('active-modal')
      return

    # after the model closes
    $(document).on 'closed.fndtn.reveal', '#modal_productInterstitial[data-reveal]', =>
      # console.log "model closed"

      @$modalLoader.hide()

      $thisSlickBuild = @$modalProduct.find('.slick-build')
      $thisSlickBuild.slick('unslick') if $thisSlickBuild.hasClass('slick-initialized')
      @slideBuildProduct = null
      $('html').removeClass('active-modal')
      return

    return

  initializeCompontentToolbar:()->
    window.keyEvent = ''
    $toolbarSearchEl = $('#toolbarSearch')
    $searchLoaderEl = $('.search-loading .loader')

    searchIsEmpty=()->
      if $toolbarSearchEl.val().length < 1
        return true
      else
        return false

    loadingToggle=(state)->
      if state is 'on'
        $toolbarSearchEl.removeClass('active')
        $searchLoaderEl.fadeIn('fast')

      else if state is 'off'
        $.when($searchLoaderEl.fadeOut('fast')).then () ->
          if searchIsEmpty()
            $toolbarSearchEl.removeClass('active')
          else
            $toolbarSearchEl.addClass('active')
      return


    do filterSetupSearch=()=>
      clearSearch=(render = true)=>
        # console.log "should I render? ",render
        loadingToggle('off')
        @toggleMasterClear()

        if render
          @productCollectionFiltered.removeFilter('search')
          @collectionFiltered_render()

        return

      newSearch = _.debounce(((e) =>
        search = $toolbarSearchEl.val()
        searchSet = null

        if search.length < 2
          loadingToggle('off')
          return

        if window.keyEvent.which is 0 and window.keyEvent.ctrlKey and window.keyEvent.metaKey and window.keyEvent.altKey
          loadingToggle('off')
          return

        # console.time('search')

        @filterBy_Search(search)

        loadingToggle('off')

        @toggleMasterClear()
        # console.timeEnd('search')
        return

      ), 500)

      # typing in the search field
      $toolbarSearchEl.keypress (e) ->
        window.keyEvent = e
        loadingToggle('on')
        newSearch()
        return

      # if user deletes the search text - reset
      $toolbarSearchEl.keyup (e) =>
        if e.keyCode is 46 or e.keyCode is 8
          clearSearch() if searchIsEmpty()
        return

      # click the x button and reset the search
      $('.reset-search').click (e) =>
        e.preventDefault()
        $toolbarSearchEl.val("")
        clearSearch()
        return

    do filterSetupWarranty=()=>
      $warrantyDropdownEl = $('#filter_warranty')
      $warrantyTitleEl = $('.filter-warranty-dropdown .title')

      $warrantyDropdownEl.find('input').click (e) =>
        # e.preventDefault()

        $listEl = $(e.target).closest('li')
        thisAction = $(e.target).data('action')

        unless $listEl.hasClass('reset')
          $listEl.addClass('selected')
          $warrantyTitleEl.text("Warranty: "+$listEl.find('span').text())

        if thisAction is 'reset'
          @compontentToolbarReset('warranty')

        else if thisAction is 'yes'
          @filterBy_Warranty(true)

        else if thisAction is 'no'
          @filterBy_Warranty(false)

        return

      return

    # click reset master
    $('.reset-master').click (e) =>
      e.preventDefault()
      $(e.target).fadeOut('fast')
      @compontentToolbarReset()
      return

    # $('.reset-master').show()
    @

  compontentToolbarReset:(filter = '')->
    $toolbarEl = $('#productFilter')

    resetWarranty=()=>
      $toolbarEl.removeClass('active-warranty').find('.filter-warranty-dropdown .title').text("Warranty")
      @productCollectionFiltered.removeFilter('warranty')
      $toolbarEl.find('#filter_warranty .selected').removeClass('selected').find('input').prop('checked', false)

      return

    resetSearch=()=>
      # reset the search
      $toolbarEl.removeClass('active-search').find('#toolbarSearch').val("").removeClass('active')
      @productCollectionFiltered.removeFilter('search')
      return

    resetColorfamily=()=>
      # reset the color family
      $toolbarEl.removeClass('active-colorfamily').find('.filter-color-dropdown .title').text("Color")
      $toolbarEl.find('.color-index').removeClass('active')

      _.each @colorViews, (view, key, list)->
        view.reset()

      @productCollectionFiltered.removeFilter('colorfamily')
      return

    if filter is 'warranty'
      resetWarranty()
      @buildProductIndex(@productCollectionFiltered)

    else if filter is 'search'
      resetSearch()
      @buildProductIndex(@productCollectionFiltered)

    else if filter is 'colorfamily'
      resetColorfamily()
      @buildProductIndex(@productCollectionFiltered)

    else
      resetSearch()
      resetColorfamily()
      resetWarranty()
      @buildProductIndex(@productCollection)

    return

  #///

  sortResult: (data)->
    type = null

    #  determine the type
    # collection:   regular index load
    # model:        search filter
    # object:       color filter

    # console.log data

    if data.model?
      type = 'collection'

    else if data[0].id?
      type = 'model'

    else
      type = 'object'

    # console.log "this product set is a "+type+" type"

    getDataFromModel=(data, filter)->
      if type is 'model'
        return _.sortBy data, (model) ->
          return model.attributes[filter]

      else
        return _.sortBy data, (obj) ->
          return obj.model.attributes[filter]

    getDataFromCollection=(data, filter)->
      data.comparator = (model) ->
        parseInt(-model.get(filter))

      # Resort collection
      data.sort()

      return data

    # sort the data by quantity
    if type is 'collection'
      data = getDataFromCollection(data, 'dyelotTotal')

    else
      data = getDataFromModel(data, 'dyelotTotal').reverse()

    # console.log "returning data: ",data

    return data

  # main product grid render complete
  renderComplete: ()->

    updateStyles=()=>
      @$productGridParentEl.addClass('ready')
      # .css('min-height', @$productGridParentEl.css('height'))
      $('#productGridTop .loader').css('height', '0px')
      # $(document).foundation('tooltip', 'reflow')
      # $(document).foundation('equalizer', 'reflow')
      return

    updatedFailedImages=()=>
      _.each window.Vars.failedImages, (img, key, list)=>
        thisModel = @productCollection.get({ cid: img.modelID})

        if thisModel?
          thisModel.set('imgBroken', true)
          thisModel.attributes.images.config.baseURL = '//media.interface.com/is/image/InterfaceInc/logo_placeholder?resmode=sharp'

      return

    @$productGridParentEl.imagesLoaded().always((instance) =>
      # console.log "img load watch complete"

      # if not App.live.admin
      #   updateStyles()

      if window.Vars.failedImages.length > 0
        updatedFailedImages()
        # console.warn "Failed scene7 urls: ", window.Vars.failedImages

      return
    ).done((instance) =>
      # console.log "img load done"
      return
    ).fail((instance) ->
      # console.log "img load fail ",instance
      return
    ).progress (instance, image) ->

      result = (if image.isLoaded then "done" else "fail")

      if result is 'fail'
        image.failedUrl = image.img.currentSrc
        image.modelID = $(image.img).data('id')
        window.Vars.failedImages.push(image)
        $(image.img).attr('src', '//media.interface.com/is/image/InterfaceInc/logo_placeholder?$300x300$')

    # if we are in admin section load the product grid without waiting for images
    if App.live.admin
      updateStyles()
      window.appReady()

    else
      updateStyles()

    return

  # initial app render
  render: ()->

    # sort the collection
    sortedCollection = @sortResult(@productCollection)

    # assign views / append templates to container
    @buildProductIndex(sortedCollection)

    @

  renderEmpty: ()->
    # reset tile views
    @clearProductIndexViews()

    # reset count
    @gridProductCount = 0

    # clear out the container
    @containerProductIndex.empty()
    @

  # admin render
  renderCustomColorView: (tileModel, tileEl, key)->
    # console.log "renderCustomColorView"
    tileID =  tileModel.get('id')
    foundModel = null
    foundModelSuccess = false

    searchCustomColorModels=(thisID)->
      _.each App.data.customColors.models, (model, key, list)->
        if model.id is thisID
          foundModelSuccess = true
          foundModel = model
          return
      return foundModel

    # fetch the model from the custom color collection
    foundModel = searchCustomColorModels(tileID)

    if foundModelSuccess is false
      newAttributes = {
        'id': tileID
      }

      newColorModel = new App.structure.model.customColor(newAttributes)
      App.data.customColors.add(newColorModel)

      foundModel = searchCustomColorModels(tileID)

    parentData = {
      'id': tileID
      'tileEl': tileEl
    }

    # assign this model to a custom color view
    @customColorViews[key] = new App.structure.view.customColorItem(
      model: foundModel
      parentData: parentData
    )

    # build the html
    newEl = @customColorViews[key].buildPanel().el
    containerCustomColors = $(tileEl).find('.edit')
    containerCustomColors.append(newEl)

    # render the el html
    @customColorViews[key].render()

    return

  # renderColorFilter: (resultSet)->
  #   console.log "renderColorFilter"
  #   @filterResultsColor = []
  #   @containerProductIndex.empty()
  #   @gridProductCount = 0

  #   # reset tile views
  #   @tileViews = []

  #   # reportObj = {}
  #   # Report = (rank, factoryColor) ->
  #   #   @rank = rank
  #   #   @factoryColor = factoryColor
  #   #   return

  #   # sort
  #   @colorFilterSet = @sortResult(resultSet)

  #   # each collection
  #   _.each @colorFilterSet, (obj, key, list) =>
  #     model = obj.model
  #     @filterResultsColor.push(model)

  #     # reporting
  #     # thisName = model.get('product').name+" "+model.get('product').colorNumber
  #     # reportObj[thisName] = new Report(Math.round(obj.rank), model.get('source').productcolorfamily)

  #     # console.log "Rank:"+Math.round(obj.rank)+" | "+model.get('product').name+" "+model.get('product').colorNumber+". Original: "+model.get('source').productcolorfamily


  #     # assign this model to a product tile view
  #     @tileViews[key] = new App.structure.view.productTile(
  #       model: model
  #     )

  #     # build the html
  #     newEl = @tileViews[key].render().el

  #     # render the el html
  #     @containerProductIndex.append(newEl)

  #     @gridProductCount++

  #   # console.table(reportObj)

  #   # _.delay =>
  #   #   @renderComplete()
  #   # , 300

  #   @
  # ///

  # product tile activities
  updateOrderForm:(updateOrderType)->

    # swap elqFormName if sample
    if updateOrderType is 'sample'
      document.forms["2015FlashSale"].elqFormName.value = "FlashSale_SampleOrders"

    else
      document.forms["2015FlashSale"].elqFormName.value = "2015FlashSale"

    return

  calcTabHeight:()->

    headerControlHeight = 43 if $('.header-controls').outerHeight() < 1

    if Foundation.utils.is_medium_up()
      offset = headerControlHeight
    else
      offset = headerControlHeight + $('.modal-header').outerHeight()

    $('.tabs-content').css('height', ($('.reveal-modal').height() - offset)+'px')
    return

  buildTabOrder:()->
    # set the order type if we are coming from detail tab
    if @tabRequestFromTile is 'detail'
      orderType = 'sample'

    else
      orderType = @tabRequestFromTile

    $formEL = $('form.order-form')
    $accountFieldset = $formEL.find('fieldset.account-info')
    $orderTypeRadio = $(".toggle-order")
    updateOrderType = false

    @calcTabHeight()

    # The Form Functions
    # ---

    # reset order form
    do resetOrderForm=()=>
      # reset form
      $('.userinfo-data').empty()
      $('.email-info').removeClass('hide')
      $('.success-message').removeClass('active')
      $(".field-quantity").val('')
      $("textarea.question").val('')

      # Clear the error classes on divs and labels
      $formEL.children("div").removeClass "error"
      $formEL.children("label").removeClass "error"
      $formEL[0].reset()
      return

    # render this product data to the form
    do updateFormWithModel=()=>
      window.alias_activeProduct = @activeProduct

      # build the form backend data
      $containerFormData = $('#data .attributes').empty()
      formDataBuilder = _.template($("#modal_form_backend_data").html())


      filteredAttributes = {}

      # grab data according to eloqua form labels
      # console.log "grab data: ", @activeProduct.attributes.product

      filteredAttributes.productPrice = '0.00'
      filteredAttributes.productName = @activeProduct.get('product').name
      filteredAttributes.productColorNumber = @activeProduct.get('product').colorNumber
      filteredAttributes.productColorName = @activeProduct.get('product').colorName
      filteredAttributes.productColor = @activeProduct.get('source').COLOR or ''
      filteredAttributes.productColorFamily = @activeProduct.get('source').COLORFAM or ''
      filteredAttributes.productSizeLabel = @activeProduct.get('product').sizeLabel
      filteredAttributes.productPDS = @activeProduct.get('source').THIRDITEM or ''
      filteredAttributes.productE1 = @activeProduct.get('source').E1ITEM or ''

      filteredAttributes.productQuantity = @activeProduct.get('dyelotTotal')

      # console.log "original: ", @activeProduct.attributes.source
      # console.log "new: ", filteredAttributes

      _.each filteredAttributes, (v, key, list) =>
        vars = {productDataKey: key, productDataVal: v}
        $containerFormData.append(formDataBuilder(vars))

      # build the dyelots
      dyelotTemplate = _.template($("#modal_form_dyelots").html())
      dyelotTotal = 0

      $('#dyelots').empty()
      _.each @activeProduct.get('dyelots'), (obj, key, list)->
        dyelotMarkup = dyelotTemplate(obj)
        $('#dyelots').append(dyelotMarkup)
        dyelotTotal += parseInt(obj.quantity)

      if @activeProduct.get('dyelots').length > 1
        $('.dyelot-total').html(Math.round(dyelotTotal)+' yds²').data('total', dyelotTotal).closest('tfoot').show()
      else
        $('.dyelot-total').data('total', dyelotTotal).closest('tfoot').hide()


      # toggle warranty
      if @activeProduct.get('product').warranty is false
        $('.warranty').addClass('active')
      else
        $('.warranty').removeClass('active')


      return

    # handle form submission and validation
    do watchOrderFormSubmission=()=>

      return if $formEL.hasClass('submission-on')

      appAjaxPost = @formAjaxPost

      # form submission moment
      $formEL.on("invalid.fndtn.abide", ->
        console.log "orderType: "+orderType
        console.log "product order form invalid"
        return

      ).on "valid.fndtn.abide", ->
        thisForm = $(@)
        $('.submit-loading').fadeIn()

        newAddress = $(@).find('input.field_address1').val()
        newCity = $(@).find('input.field_city').val()
        newZip = $(@).find('input.field_zipPostal').val()

        if not _.isEmpty(newAddress)
          Vars.user.field_address1 = newAddress

        if not _.isEmpty(newCity)
          Vars.user.field_city = newCity

        if not _.isEmpty(newZip)
          Vars.user.field_zipPostal = newZip

        # sync the two different order type inputs
        # if orderType is "sample"

        #   totalRequest = $('#sampleQuantity').val()
        #   $('#materialRequestQuantity').value(totalRequest)

        #   # $("[name=QuantityRequested]")[0].value = $("[name=SampleQuantityRequested]")[0].value
        #   # $("[name=SampleQuantityRequested]")[0].value = 0

        # else
        #   $("[name=SampleQuantityRequested]")[0].value = 0

        appAjaxPost(thisForm.serialize(), orderType)
        return

      # watchOrderFormSubmission should only run once since the form is always in markup
      $formEL.addClass('submission-on')
      return

    # populate user data if we have it
    do updateUserData=()=>

      # builds the plain text user data summary
      buildLabel = (className, value)->
        @$labelEl = $("<label>",
          class: className
        ).html(value)
        return @$labelEl

      $labelContainer = $('.userinfo-data')
      fullname = ''
      state = ''
      cistyState = ''

      if not _.isEmpty(Vars.user)

        highlightEmpty = 0
        _.each Vars.user, (value, key, list)->
          if value is ''
            $formEL.find('.'+key).closest('.row').addClass('highlight')
            highlightEmpty++
            return

          $fieldEL = $formEL.find('.'+key)

          # build user data summary
          if key is 'field_name_first' or key is 'field_name_last'
            fullname += (value+' ')
            $newLabel = buildLabel('label_field_name', fullname) if key is 'field_name_last'

          if key is 'field_stateProv'
            state = value

          if key is 'field_city'
            cityState = value+' '+state
            $labelContainer.append(buildLabel('label_'+key, value))
            $newLabel = buildLabel('label_field_cityState', cityState)

          else
            $newLabel = buildLabel('label_'+key, value)

          $labelContainer.append($newLabel)

          # update form fields
          $fieldEL.attr('value', value)

          $accountFieldset.addClass('hide-'+key) if not _.isEmpty value

        if highlightEmpty > 1
          $('.account-info').addClass('highlightedFields')
          $('.profile').removeClass('complete-data')
        else
          $('.profile').addClass('complete-data')
          $('.account-info').removeClass('highlightedFields')

      else
        console.log "no user data"
        if not $('.profile').hasClass('new')
          $('.profile').addClass('new').find('.update').trigger('click')

      return

    # validate the user entered quantity against the max available
    do watchQuantityRequest=()=>
      # request more than available logic
      $overQuantityEL = $formEL.find('.over-quantity')
      $exceedAlertEL = $formEL.find('.close.dismiss')
      $quantityEL = $formEL.find('.data-quantity')
      totalAvailable = $('.dyelot-total').data('total')


      $(".setTotal").on "click", =>
        $(".field_quantity").val(totalAvailable)
        $overQuantityEL.slideUp('fast')
        false

      $(document.body).on "input",".field_quantity", ->
        console.log "input quantity"
        totalPrice = $(@).val() * totalAvailable
        totalQuantity = $(@).val()
        newQuantity = $quantityEL.data('value') - totalQuantity
        newQuantity = Math.round(newQuantity * 100) / 100

        _.delay ->
          if newQuantity < 0
            $overQuantityEL.stop().slideDown 'slow', ->
              $(document).foundation('equalizer', 'reflow')
              return

          else
            $overQuantityEL.stop().slideUp('fast')
        , 900

        $exceedAlertEL.click (e)->
          e.preventDefault()
          $overQuantityEL.slideUp('fast')
          false
        return

      return

    # show / hide elements based on order type
    @updateOrderForm(orderType)

    # select the order type radio button
    _.each $orderTypeRadio, (el, key, list) ->
      thisVal = $(el).attr('value')

      if $(el).attr('value') is orderType
        $(el).trigger('click')

    _.delay ->
      $(document).foundation('equalizer', 'reflow')
    , 200

    # exit buildTabOrder
    return

  buildTabDetail:()->
    if @slideBuildProduct is @activeProduct
      console.log "slide already built"
      return

    $('#panel_detail').addClass('loading')

    $modalHeader = $('.reveal-modal .modal-header')
    $slickBuildEl = $('.slick-build').addClass('loading')
    $imgConfigEl = $('#panel_detail').find('img.config')
    $imgSceneEl = $('#panel_detail').find('img.scene')
    $imgtileEl = $('#panel_detail').find('img.tile')

    buildScene7=(squareValue)=>
      # generate a mixed media viewer
      serverurl = 'http://interfaceinc.scene7.com/is/image/'

      thisImgConfig = @activeProduct.get('images').config.baseURL
      thisImgTile = @activeProduct.get('images').tile.baseURL

      asset1 = thisImgTile.slice(36)
      asset2 = thisImgConfig.slice(36)

      newGallery = new (s7viewers.MixedMediaViewer)(
        'containerId': $mixedMediaEl.attr('id')
        'params':
          'asset': asset1+','+asset2
          'serverurl': serverurl

        'handlers': 'initComplete': ->
          console.log 'Viewer initialized'
          return

        'localizedTexts':
          'en': 'CloseButton.TOOLTIP': 'Close'
          'fr': 'CloseButton.TOOLTIP': 'Fermer'
          defaultLocale: 'en')

      newGallery.init()

      console.log newGallery

      return

    assignSrc=(squareValue)=>
      return false if @activeProduct.get('imgBroken')

      thisImgConfig = @activeProduct.get('images').config.baseURL+"&wid="+squareValue+"&align=-1,0&fit=crop"
      thisImgScene = @activeProduct.get('images').scene.baseURL+"&wid="+squareValue

      if @activeProduct.get('plank') is true
        thisImgTile = @activeProduct.get('images').tile.baseURL+"?hei="+squareValue+"&wid="+squareValue+"&align=-1,0&fit=vfit&bgc=238,238,238"
        $imgtileEl.attr('src', thisImgTile).parent().addClass('plank')

        # hei=623&wid=623&align=-1,0&fit=vfit&bgc=238,238,238

      else
        thisImgTile = @activeProduct.get('images').tile.baseURL+"?wid="+squareValue+"&align=-1,0&fit=crop"
        $imgtileEl.attr('src', thisImgTile)

      $imgConfigEl.attr('src', thisImgConfig)
      $imgSceneEl.attr('src', thisImgScene)

      $('.slick-nav').css('width', squareValue+'px')

      return true

    buildSlick=()=>
      activeProductAlias = @activeProduct
      thumbSize = Math.round( $('.slick-nav button').width() )

      $slickBuildEl.on 'init', (event, slick, currentSlide, nextSlide) ->
        $('#panel_detail').removeClass('loading')
        $slickBuildEl.removeClass('loading')
        $(document).foundation('equalizer', 'reflow')

        _.each $('.slick-dots').find('button'), (el, key, list)->

          if key is 0
            thisURL = activeProductAlias.get('images').tile.baseURL+"?wid="+thumbSize+"&hei="+thumbSize+"&align=-1,0&fit=crop"

          if key is 1
            thisURL = activeProductAlias.get('images').config.baseURL+"&wid="+thumbSize+"&hei="+thumbSize+"&align=-1,0&fit=crop"

          if key is 2
            thisURL = activeProductAlias.get('images').scene.baseURL+"&wid="+thumbSize+"&hei="+thumbSize+""

          $(el).css('background-image', 'url('+thisURL+')')

        return

      $slickBuildEl.slick
        slidesToShow: 1
        dots: true
        infinite: true
        speed: 100
        cssEase: 'linear'
        # appendArrows: $('.slick-nav')
        arrows: false
        # prevArrow: $('.slick-nav .back')
        # nextArrow: $('.slick-nav .forward')
        appendDots: $('.slick-nav')

      return true

    imageLoadComplete=()=>
      # debugger
      @$modalLoader.fadeOut()
      @slideBuildProduct = @activeProduct

      buildSlick()
      return

    imageLoadWatch=(logsEnabled)=>

      $('body').find('.slick-build').imagesLoaded().always((instance) =>
        console.log "img load watch complete" if logsEnabled

        return
      ).done((instance) =>
        console.log "img load done" if logsEnabled
        imageLoadComplete()
        return

      ).fail((instance) ->
        console.log "img load fail"
        return

      ).progress (instance, image) ->
        if logsEnabled
          result = (if image.isLoaded then "done" else "fail")
          whichImage = image.img.className.split(/[ .]+/)[0]
          console.log whichImage+" load progress: ",result
          console.log image

      return

    calcHeight=()->
      componentHeight_header = $('.header-controls').outerHeight()
      componentHeight_slideControls = $('.slick-nav button.hide').width() + 10

      if Foundation.utils.is_medium_up()
        finalHeight = $('#modal_productInterstitial .view-container').height() - (componentHeight_header + componentHeight_slideControls)

      else
        finalHeight = $('#modal_productInterstitial .view-container').height() - ($('.modal-header').height() + componentHeight_header + componentHeight_slideControls)

      if finalHeight > $('.modal-content').width()
        finalHeight = Math.round($('.modal-content').width())

      return finalHeight

    buildElements=(imgHeight)=>
      @calcTabHeight()

      # render images
      loadImages = assignSrc(imgHeight)

      if loadImages is false
        placeholderURL = '//media.interface.com/is/image/InterfaceInc/logo_placeholder?resmode=sharp&wid='+imgHeight
        $imgConfigEl.attr('src', placeholderURL)
        $imgSceneEl.hide()
        $imgtileEl.hide()
        @$modalLoader.fadeOut()
        @slideBuildProduct = @activeProduct
        $('#panel_detail').removeClass('loading')
        $slickBuildEl.removeClass('loading')
        $(document).foundation('equalizer', 'reflow')

      else
        $imgSceneEl.show()
        $imgtileEl.show()

        imageLoadWatch(logsEnabled = false)
      return

    # delay of shame - this should be based off of loading not delay
    _.delay =>
      # console.log "first delay"
      imgHeight = calcHeight()

      if imgHeight < 0
        _.delay =>
          # console.log "final delay"
          imgHeight = calcHeight()
          buildElements(imgHeight)
        , 500

      else
        buildElements(imgHeight)

    , 500

    return

  buildTabDownload:()->
    console.log "ini downloads"
    return

  selectNewTab:(tabRequest)->
    # activate the requested tab...
    $('#modalTabs .tab-title a[href='+tabRequest+']').trigger('click')
    @calcTabHeight()
    return

  openModal:($tileButton)->

    # open the product interstitial modal
    @$modalLoader.show()
    @$modalProduct.foundation 'reveal', 'open'

    @$modalProduct.removeClass('panel_detail, panel_order')
    @$modalProduct.addClass($tileButton.attr('href').slice(1))

    # trigger new tab
    @selectNewTab($tileButton.attr('href'))

    return
  #///


  # product form activities
  formAjaxPost:(serializedData, orderType) ->
    currentTime = new Date()
    action = 'https://secure.eloqua.com/e/f2'
    console.log window.alias_orderType = orderType
    # pd dev test please ignore

    window.formSubmitError = (data) =>
      console.log "formSubmitError ", data['status']
      location.reload() if confirm("We've encounted an issue. Please refresh the page and try again.")
      $('.submit-loading').fadeOut()
      return

    window.formSubmitSuccess = (data) =>
      thisID = window.alias_activeProduct.get("id")
      $thisEl = $('#'+window.alias_activeProduct.cid)
      # ga('send', 'event', [eventCategory], [eventAction], [eventLabel], [eventValue], [fieldsObject]);

      try
        ga('send', 'event', 'form submission', 'material request', 'success',thisID)

        if window.alias_orderType is 'sample'
          # $productEL.addClass('sample')
          ga('send', 'event', 'form submission', 'sample', 'success',thisID)
        else
          # $productEL.addClass('request')
          ga('send', 'event', 'form submission', 'material request', 'success',thisID)

      catch e
        console.log "google analytics failed"

      console.log "formSubmitSuccess ", data['status']

      if window.alias_orderType is 'sample'
        statusClass = 'active-s'

      else
        statusClass = 'active-o'

      $thisEl.find('.status').addClass(statusClass)

      $('#modal_success').foundation('reveal', 'open')

      $('.submit-loading').fadeOut()

      return

    $.ajax
      url: action
      type: "post"
      dataType: 'jsonp'
      contentType: 'jsonp'
      data: serializedData+'&nocache='+currentTime.getTime()
      jsonpCallback: "elqJSONCallback"
      success: (data) =>
        window.formSubmitSuccess(data)
        return

      error: (data) =>
        unless (data["status"] is 200) or (data["status"] is 404)
          window.formSubmitError(data)

        else
          window.formSubmitSuccess(data)
        return

    return



  initializeProductForm: ()->
    # show auto-populated fields
    $profileUpdate = $('.profile .update')
    $accountInfo = $('.account-info')
    $updateFields = $('.update-fields')

    syncPanelHeights = (sourceEl)->
      $('.modal-header, .modal-content').removeAttr('style')
      updatedHeight = $('.modal-content').height()
      $('.modal-header, .modal-content').css('min-height', updatedHeight+"px")
      return

    $profileUpdate.click (e)->
      e.preventDefault()
      $('.profile').toggleClass('edit').removeClass('complete-data')
      # $accountInfo.find('.row').not(".sample, .order").slideDown()
      # $profileUpdate.hide()
      # $updateFields.show()

      false

    $updateFields.click (e)->
      e.preventDefault()
      $formEL = $('form.order-form')
      $('.profile').toggleClass('edit').removeClass('complete-data')
      # $accountInfo.find('.row').slideUp()
      # $profileUpdate.show()
      # $updateFields.hide()

      # populate user data if we have it
      if not _.isEmpty(Vars.user)
        fullname = ''
        _.each Vars.user, (value, key, list)->
          newVal = $formEL.find('.'+key).val()

          if key is 'field_name_first' or key is 'field_name_last'
            fullname += (newVal+' ')
            $formEL.find('.label_field_name').text(fullname) if key is 'field_name_last'

          else
            $formEL.find('.label_'+key).text(newVal)



      false

    updateTabRequestFromTile = (updateOrderType) =>
      @tabRequestFromTile = updateOrderType
      return

    $('.toggle-order').on 'change', ->
      if $(@).prop('checked')
        updateOrderType = $(@).attr('value')

        # console.log "change order type to: "+updateOrderType

        # update radio styles
        $('.input-toggle-index label').removeClass('active')
        $(@).parent().addClass('active')

        # format form fields
        $('#formType').attr('class', '').addClass(updateOrderType)

        App.live.activeViews.app.updateOrderForm(updateOrderType)

        updateTabRequestFromTile(updateOrderType)


      return

    return

  initializeSubscriptionForm: ()->
    $subFormEl = $('#subscribe')
    $promoEl = $(".promotion")

    resetTopBar=()->
      _.delay ->
        $(document).foundation('topbar', 'reflow')
      , 500
      return

    if $subFormEl.hasClass('submission-on')
      console.log "exit"
      return

    if parseInt($.cookie('subscribed')) is 1 or parseInt($.cookie('promoHide')) is 1

      console.log "dismiss promo"
      $promoEl.find('.form-cta').addClass('hide')
      $promoEl.find('.message').removeClass('hide')
      $promoEl.removeClass('un-subscribed')

    else
      $promoEl.addClass('un-subscribed')
      resetTopBar()
      # console.log "subscribed no",$.cookie('subscribed')

    synchEloquaData = ()->
      $formSubEl = $('form#subscribe')
      $formEloquaEl = $('form.eloqua-data')

      $formSubEl.attr('value', $formEloquaEl.find('.guid').val())
      $formSubEl.attr('value', $formEloquaEl.find('.cookie').val())
      $formSubEl.attr('value', $formEloquaEl.find('.siteID').val())

      return

    # after successful post
    window.successSubscribe=()->
      $.cookie("subscribed",1, {expires: 365})

      try
        ga('send', 'event', 'subscribe', 'success')
      catch e
        console.log "google analytics not loaded"

      $promoEl.find('.form-cta').addClass('hide')
      $promoEl.find('.message').removeClass('hide')
      $promoEl.delay(3000).queue ()->
        $promoEl.removeClass('un-subscribed')
        $(this).dequeue()

      return

    # post via ajax to eloqua
    post=(postData)->
      currentTime = new Date()
      action = 'https://secure.eloqua.com/e/f2'

      $.ajax
        url: action
        type: "post"
        dataType: 'eloquaResponse'
        data: postData+'&nocache='+currentTime.getTime()
        accepts: 
          eloquaResponse: 'text/html'
        
        success: (data) ->
          # console.log "success"
          # console.log data
          window.successSubscribe()
          return

        error: (data) ->
          unless data["status"] is 200
            # console.log "error"
            # console.log data
            location.reload() if confirm("We've encounted an issue. Please refresh the page and try again.")
          else
            # console.log "error success"
            # console.log data
            window.successSubscribe()
          return
      return

    # abide validation conditionals
    $subFormEl.on("invalid.fndtn.abide", ->
      console.log "invalid"
      return

    ).on "valid.fndtn.abide", (e) ->
      e.preventDefault()
      # console.log "valid"
      synchEloquaData()
      post($(@).serialize())
      return false

    # this function should only run once since the form is always in markup
    $subFormEl.addClass('submission-on')

    $('#promotionDismiss').click (e) ->
      e.preventDefault()
      $.cookie("promoHide",1, {expires: 365})
      $promoEl.removeClass('un-subscribed')

      resetTopBar()

      false

    return
  # ///

  # color filter subnav activities
  loadColorFilter: ()->
    # console.log "Load colors"

    @colorCollection = App.data.colorFamilies
    @colorContainer = $('#color-view')
    @$closeEl = $('#color-view-reset').detach() if _.isUndefined(@$closeEl)
    @colorContainer.empty()

    # each collection
    _.each @colorCollection.models, (model, i, list) =>

      @colorViews[i] = new App.structure.view.colorTile(
        model: model
      )

      newEl = @colorViews[i].render().el

      # render the el
      @colorContainer.append(newEl)

      if i is (list.length - 1)
        @colorContainer.prepend(@$closeEl.html())

    # reset color filter
    $('.color-tile-view-close').click (e) =>
      # @clearColorFilters()
      @compontentToolbarReset('colorfamily')
      return false

    @

  toggleColorFilter: (e)->
    e.preventDefault()
    # console.log "clicked on filter button"
    return

  initializeColorControls: ()->

    # Product Index Subnav
    $productGrid = $('.product-grid')

    $('.section-subnav .view-toggle').click ()->
      $viewToggleParent = $(@).closest('.nav-item')

      $productGrid.removeClass('view-tile view-config view-scene')

      active = $(@).data('view')

      $productGrid.addClass('view-' + active)

      $viewToggleParent.find('.active').removeClass('active')
      $(@).parent().addClass('active')

      false
    return
  #///

  # toolbar actions
  toolbarActivity: ()->
    if @activeFilterColor and @activeFilterSearch
      return 2

    if (@activeFilterColor and not @activeFilterSearch) or (@activeFilterSearch and not @activeFilterColor)
      return 1

    if not @activeFilterColor and not @activeFilterSearch
      return 0

  toggleMasterClear: ()->
    # if @toolbarActivity() is 2
    #   # console.log "active master clear"
    #   $('.reset-master').fadeIn('fast')
    # else
    #   # console.log "hide master clear"
    #   $('.reset-master').fadeOut('fast')
    return
  #///

  # toolbar filters
  filterBy_Warranty: (warranty)->
    @clearFilter('warranty')
    $('#productFilter').addClass('active-warranty')
    # console.log "warranty is: ",warranty
    # console.log "out of: ",@productCollectionFiltered.models.length

    @productCollectionFiltered.filterBy 'warranty', (model) ->
      if model.get('product').warranty is warranty
        return model

    # console.log "found: ",@productCollectionFiltered.models.length

    @collectionFiltered_render()
    return

  filterBy_Search: (search)->
    @clearFilter('search')
    $('#productFilter').addClass('active-search')
    # console.log "started with "+@productCollectionFiltered.models.length

    @productCollectionFiltered.filterBy 'search', (model) ->
      if model.get('product').name.toLowerCase().indexOf(search.toLowerCase()) > -1
        return model
      else if model.get('product').colorNumber.indexOf(search.toLowerCase()) > -1
        return model
      else if model.get('product').patternNumber.toLowerCase().indexOf(search.toLowerCase()) > -1
        return model

    # console.log "found: "+@productCollectionFiltered.models.length

    @collectionFiltered_render()

    return

  # requested by an individual color item view in the toolbar dropdown
  filterBy_Color: (colorFamilyName)->
    @clearFilter('colorfamily')
    $('#productFilter').addClass('active-colorfamily')
    # console.log "searching for: ",colorFamilyName
    # console.log "out of: ",@productCollectionFiltered.models.length

    @productCollectionFiltered.filterBy 'colorfamily', (model) ->
      if _.indexOf(_.keys(model.get('colorFamily')), colorFamilyName) > -1
        return model

    # console.log "found: ",@productCollectionFiltered.models.length

    @collectionFiltered_render()

    return

  clearFilter: (filterName)->
    # console.log "what filters are already applied to productCollectionFiltered?"
    # console.log @productCollectionFiltered.getFilters()

    if _.indexOf(@productCollectionFiltered.getFilters(), filterName) > -1
      # console.log "remove the existing "+filterName+" filter"
      @productCollectionFiltered.removeFilter(filterName)

    return

  # after a filter is applied: if there's a result render - otherwise display blank
  collectionFiltered_render: ()->
    if @productCollectionFiltered.models.length > 0
      @buildProductIndex(@productCollectionFiltered)

    else
      @renderEmpty()
    return
  # ///

  # admin custom color interface // depricated
  initializeCustomColors: ()->
    return if !$('body').hasClass('admin')

    # console.log "initializeCustomColors"

    @customColorTemplate = @$('#custom_color_items')

    FBCollection_customColor = Backbone.Firebase.Collection.extend(
      model: App.structure.model.customColor
      url: "https://interfacespecials.firebaseio.com/customColorFamily"
      autoSync: true)

    @customColorCollection = new FBCollection_customColor

    @customColorCollection.on 'sync', (collection) ->
      console.log 'collection is loaded', collection
      return

    # @listenTo @customColorCollection, 'add', @addCustomColor
    return

  # admin custom color interface // depricated
  addCustomColor: (inheritedModel)->

    console.log "addCustomColor"

    # assign this model to a product tile view
    thisView = new App.structure.view.customColorItem(
      model: inheritedModel
    )

    # build the html
    newEl = thisView.render().el

    # render the el html
    @customColorTemplate.append(newEl)
    return
  #///


  clearProductIndexViews: ()->
    return if @tileViews.length < 1

    _.each @tileViews, (view, key, list)->
      view.destroy_view()
      return

    return

  # new render
  buildProductIndex: (collection)->

    # reset tile views
    @clearProductIndexViews()

    # reset count
    @gridProductCount = 0

    # clear out the container
    @containerProductIndex.empty()

    # each collection model
    _.each collection.models, (model, key, list) =>
      # Vars.results.total++

      # assign this model to a product tile view
      @tileViews[key] = new App.structure.view.productTile(
        model: model
      )

      # build the html
      newEl = @tileViews[key].render().el

      # render the el html
      @containerProductIndex.append(newEl)

      # render the a custom color view if we have a match
      # if model.get('customColors')
      if App.live.admin
        @renderCustomColorView(model, newEl, key)

      @gridProductCount++

    _.delay =>
      @renderComplete()
    , 300

    return
