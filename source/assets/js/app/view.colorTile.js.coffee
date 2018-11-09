
activeFilterOptions = new App.structure.collection.color()

# an individual color item in the toolbar dropdown
App.structure.view.colorTile = Backbone.View.extend(
  tagName: "li"
  className: "color-tile-view"
  template: _.template($("#product-modal-color-families").html())

  events:
    "click label": "toggleThisColor"

  initialize: (options) ->
    @$filterEl = $('.filter-color-dropdown')
    @model = options.model
    @

  toggleThisColor: (e) ->
    e.preventDefault()

    # explicitly state our intent to add a filter or remove a filter
    filterAction = if @$el.hasClass('selected') then 'remove' else 'add'

    # remove all the selected classes
    $('.color-index').find('.selected').removeClass('selected')

    # console.group(filterAction+" this filter")

    if filterAction is 'add'
      @$el.addClass('selected').find('input').prop('checked', true)
      # $('.controls').addClass('active')
      App.live.activeViews.app.filterBy_Color(@.model.get('colorFamilyName'))
      App.live.activeViews.app.activeFilterColor = true

      @$filterEl.find('.title').text(@.model.get('colorFamilyName'))

    else if filterAction is 'remove'
      # $('.controls').removeClass('active')
      # console.log "filterAction is remove"
      App.live.activeViews.app.compontentToolbarReset('colorfamily')
      App.live.activeViews.app.activeFilterColor = false

    else
      App.live.activeViews.app.activeFilterColor = false
      console.log "no filter action specified"
      console.log @$el

    # App.live.activeViews.app.toggleMasterClear()

    # console.groupEnd()
    return

  render: ->
    # push model attrs to the template
    variables = @model.attributes

    variables.label = variables.colorFamilyName.replace(/([a-z])([A-Z])/g, '$1 $2')
    variables.colorSquare = variables.label.split(/(?=[A-Z])/)[0].toLowerCase()

    @$el.html(@template(variables)).attr(
      id: @model.cid
    )

    # console.log @$el.html()

    @


  reset: ->
    @$el.removeClass('selected').find('input').prop('checked', false) if @$el.hasClass('selected')
    @

  # renderClose: ->
  #   variables = {}
  #   closeTemplate = _.template($("#color_filter_close").html())
  #   @$el.html(closeTemplate(variables))

  #   # console.log @$el.html()

  #   @
)
