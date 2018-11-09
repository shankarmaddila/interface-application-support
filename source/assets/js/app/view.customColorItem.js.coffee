window.auto_data =
App.structure.view.customColorItem = Backbone.View.extend(
  tagName: "div"
  className: "template-panel"
  templateMaster: _.template($("#product-grid-custom-color-panel").html())
  template: _.template($("#product-grid-custom-color").html())
  templateOption: _.template($("#product-grid-custom-color-option").html())
  tagTemplate: null

  # events:
  #   "click .add-new-custom-color": "add"
  #   "click .remove": "remove"

  initialize: (options) ->
    @options = options

    # console.log "initialize: ",options
    # console.log "listen to ",@model
    # @model.set('viewSet', true)
    @listenTo(@model, 'change', @render)

    @editEl = @options.parentData.tileEl

    @select2Init = false
    @

  buildPanel: (e) ->
    # console.log "buildPanel "
    masterData = {}

    # create the ul el
    @$el.html(@templateMaster(masterData)).attr(
      id: @model.cid
    )

    config = {
      tags: true
      multiple: true
      tags: window.Vars.colorData
      tokenSeparators: [","]
    }

    @tagTemplate = @$el.find('.color-tag-index').select2(config)
    # @$el.find('.js-example-data-array-selected').select2({data: data})

    @tagTemplate.on 'select2:select', (e) =>
      @addTag(e.params.data.text)
      return

    @tagTemplate.on 'select2:unselect', (e) =>
      # console.log e.params.data.text
      @removeTag(e.params.data.text)
      return

    @

  addTag: (newTag) ->
    # e.preventDefault()
    console.log "addNewCustomColor..."

    newVal = newTag
    thisID = @model.get("id")
    nextKeyPosition = 0
    newColorObj = {}
    foundModel = null
    foundModelSuccess = false

    searchCustomColorModels=(thisID)->
      _.each App.data.customColors.models, (model, key, list)->
        if model.id is thisID
          foundModelSuccess = true
          foundModel = model
          return
      return foundModel

    # does the custom color collection have this product id object?
    foundModel = searchCustomColorModels(thisID)

    # if no  - create a new model and add it to the custom color collection
    if foundModel is null
      console.warn "customColors does not have this product!"
      return

    # if yes - add this new color name to the object next in line
    justColorsObj = _.omit(foundModel.attributes, 'id')
    justColorsObj = _.keys(justColorsObj).map(Number)
    maxKey = parseInt(_.max(justColorsObj))

    if _.isNaN(maxKey)
      nextKeyPosition = 0
    else
      nextKeyPosition = maxKey + 1

    newColorObj[nextKeyPosition] = newVal

    # update local model
    foundModel.set(newColorObj, {silent: false})

    $.when(window.SpecialsFirebase_settingsRef.child('customColorFamily').child(thisID).set(foundModel.attributes)).then (data, textStatus, jqXHR) ->
      # refresh the custom color toolbar
      App.live.getCustomColors('refresh')

    return @

  removeTag: (targetTag) ->
    console.log "remove ",targetTag

    # thisID = $(e.target).attr('href')
    thisID = @model.get("id")
    thisColor = targetTag
    deleteKey = null
    foundModel = null

    foundModel = _.find App.data.customColors.models, (value, key, list)->
      return @ if value.id is thisID

    if foundModel is null
      console.error("could not find the custom color model to remove")
      return

    # find the key of the property to be deleted
    _.find foundModel.attributes, (value, key, list)->
      if value is thisColor
        return deleteKey = key

    if deleteKey is null
      console.error "could not find deleteKey"

    # update local model
    foundModel.unset(deleteKey, { silent: false })

    # update remote
    $.when(window.SpecialsFirebase_settingsRef.child('customColorFamily').child(thisID).set(foundModel.attributes)).then (data, textStatus, jqXHR) ->
      # refresh the custom color toolbar
      App.live.getCustomColors('refresh')

    return @

  render: ()->
    # console.log "render: ",@model.id

    # @$colorListUL = $(@editEl).find('.color-index')
    # @$colorListUL = $(@editEl).find('.color-tag-index')

    vars = @model.toJSON()

    # @$colorListUL.empty()
    # debugger

    markupTemplate = {}

    markupTemplate.id = vars.id

    _.each vars, (name, key, list) =>
      unless key is 'id'
        return if name is null
        markupTemplate.name = name
        # @$colorListUL.append(@template(markupTemplate))
        # @$colorListUL.append(@templateOption(markupTemplate))
        # console.log "for: ",name
        @tagTemplate.find("option[value='"+name+"']").prop("selected","selected")

    @tagTemplate.trigger("change")

    @
)
