
App.structure.view.productTile = Backbone.View.extend(
  tagName: "li"
  className: "product-item"
  template: _.template($("#product-grid").html())

  events:
    "click .toggle": "openModelTab"

  initialize: (options) ->
    # @model.on('change:imgSceneURL', @render, @)
    # App.live.activeViews.app.activeProduct
    @

  render: ->
    # console.group("product tile ",@model.cid) if @model.get('customColors')

    # show the dyelot badge if we have more than 1
    if @model.get('dyelots').length > 1
      badge = true
    else
      badge = false

    # push model attrs to the template
    variables = @model.attributes
    variables.badgeActive = badge
    variables.dyelotCount = @model.get('dyelots').length
    variables.dyelotTotal = Math.round(variables.dyelotTotal)

    if variables.product.patternNumber?
      variables.product.patternNumberLabel = variables.product.patternNumber+" /"
    else
      variables.product.patternNumber = ''

    # custom products display data differently
    if variables.product.name is "Custom"
      variables.product.title = variables.product.name+" "+variables.product.colorNumber
      variables.product.colorMeta = variables.product.patternNumber

    else
      variables.product.title = variables.product.name
      # variables.product.colorMeta = variables.product.patternNumber+" "+variables.product.colorNumber
      variables.product.colorMeta = variables.product.patternNumber



    if @model.get('dyelots').length > 1
      variables.product.quantity = variables.dyelotTotal

    # Now displaying for all products 10-27-2016
    variables.notice = '<span class="label secondary notice">Not covered by a 15-year warranty</span>'

    # set the responsive image size
    variables.responsiveSize = {
      tile: ''
      config: ''
      scene: ''
    }

    windowWidth = $(window).outerWidth()


    if Foundation.utils.is_large_up()
      sizeSetting = "wid=306"

    else if Foundation.utils.is_medium_up()
      # 740 and up
      sizeSetting = "wid=465"

    else if Foundation.utils.is_small_up()

      iphone5 = 320
      iphone6 = 375
      iphone6Plus = 414

      if windowWidth is iphone5 or windowWidth < iphone6
        sizeSetting = "wid=140"

      else if windowWidth is iphone6 or windowWidth < iphone6Plus
        sizeSetting = "wid=166"

      else if windowWidth is iphone6Plus
        sizeSetting = "wid=186"

      else
        sizeSetting = "wid=206"




    variables.responsiveSize.scene = variables.images.scene.baseURL+"&"+sizeSetting
    variables.responsiveSize.config = variables.images.config.baseURL+"&"+sizeSetting
    variables.responsiveSize.tile = variables.images.tile.baseURL+"?"+sizeSetting
    variables.modelID = @model.cid

    # render the el
    @$el.html(@template(variables)).attr(
      id: @model.cid
    )




    # console.log "for ",variables.customColors
    # if ! _.isEmpty(variables.customColors) and ! _.isEmpty( _.omit(variables.customColors, "id") )
    #   @renderCustomColorView(variables.customColors)

    # console.groupEnd() if @model.get('customColors')
    @

  addNewCustomColor: (e)->
    e.preventDefault()
    # console.log "addNewCustomColor..."

    newVal = @$el.find('.new-custom-color').val()
    thisID = @model.get("customColors").id or null
    nextKeyPosition = 0
    newColorObj = {}


    # if this tile has no custom color yet - create a new model for the colection
    if thisID is null
      thisID = @model.get('id')

      newAttributes = {
        'id': thisID
      }

      newColorModel = new App.structure.model.customColor(newAttributes)
      App.data.customColors.add(newColorModel)

    # find the color model in the firebase collection
    foundModel = _.find App.data.customColors.models, (value, key, list)->
      return @ if value.id is thisID

    # the new color being added should go next in numeric order behind the other colors
    do getNewPlacementKey=()->
      nextKeyPosition = _.keys(_.omit(foundModel.attributes, "id")).length
      newColorObj[nextKeyPosition] = newVal

    # set the model attribute
    foundModel.set(newColorObj, {silent: false})

    return

  openModelTab: (e) ->
    e.preventDefault()

    # what action we want to take
    App.live.activeViews.app.tabRequestFromTile = $(e.currentTarget).data('action')

    # set the active product model
    # console.log "active product model: ", @model
    App.live.activeViews.app.activeProduct = @model

    # activate the modal
    App.live.activeViews.app.openModal($(e.currentTarget))
    return

  destroy_view: ()->

    # // COMPLETELY UNBIND THE VIEW
    @undelegateEvents()

    @$el.removeData().unbind()

    # // Remove view from DOM
    @remove()

    Backbone.View.prototype.remove.call(@)

)
