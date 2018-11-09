class App.structure.model extends Backbone.Model
  initialize: ()->
    # console.group "Product Tile Model"

    # reset the color family
    thisColorFamObj = {}
    @.set("colorFamily", thisColorFamObj)

    thisSize = @.get("product").size

    # set plank attr
    if thisSize is '7S' or thisSize is '7A' or thisSize is '7B' or thisSize is '7C'
      @.set("plank", true)

    else
      @.set("plank", false)

    # set empty deylot if server doens't provide any
    if _.isUndefined @.get("dyelots")

      dyelots = [
        {
          'lot': '1Y1918.5'
          'quantity': '303.78'
        }
        {
          'lot': '1Y6167.5'
          'quantity': '472.42'
        }
        {
          'lot': '1Y1917.5'
          'quantity': '681.72'
        }
      ]

      @.set("dyelots", dyelots)
      @.set("dyelotCount", 3)
      @.set("dyelotTotal", 303.78)

    @.set("imgBroken", false)


    # sanitize any " . " found in the color name
    thisColorName = @.get("product").colorName
    foundKey = thisColorName.indexOf('.')

    if foundKey? and foundKey > 1
      @.get("product").colorName = thisColorName.slice(0, foundKey)


    thisName = @.get("product").name

    # convert names that end with numbers to uppercase
    if parseInt(thisName.slice(-1, thisName.length))
      @.get("product").name = thisName.toUpperCase()


    # find a string in the product name and replace it
    cleanProductName=(productName, key, replacement)=>
      foundKey = productName.indexOf(key)

      if foundKey > 0
        productName = productName.slice(0, foundKey)
        # console.log "replace "+@.get("product").name+" with "+productName+replacement
        @.get("product").name = productName+replacement

      return

    # list of strings that we want to replace in the product name
    keywordList = [
      {
        key: 'Libr'
        replacement: 'Library'
      }
      {
        key: 'Patn Li'
        replacement: 'Pattern Library'
      }
      {
        key: 'Ptn'
        replacement: 'Pattern'
      }
      {
        key: 'Pt '
        replacement: 'Pattern'
      }
    ]

    _.each keywordList, (obj, key, list)=>
      cleanProductName(@.get("product").name, obj.key, obj.replacement)


    # remove filename from image baseurl
    @cleanImage_tile = @.get('images').tile.baseURL.replace(".jpg", "")
    @.get('images').tile.baseURL = @cleanImage_tile

    # console.groupEnd()
    return

class App.structure.model.color extends Backbone.Model
  initialize: ()->
    # console.log "initialize App.structure.model.color"
    return

class App.structure.model.customColor extends Backbone.Model
  initialize: ()->

    targetID = @.get("id")
    colorsOnlyObj = _.omit(@.attributes, 'id')

    # find the product
    search = App.data.products.where({id : targetID})

    if search.length is 1

      foundModel = search[0]
      colorFamilyObj = {}

      if _.isEmpty(colorsOnlyObj)

        # update the models
        foundModel.set { customColors: false }, silent: true
        foundModel.set { colorFamily: colorFamilyObj }, silent: true

      else

        # reverse names / rank
        _.each colorsOnlyObj, (value, key, list)->
          colorFamilyObj[value] = key

        # update the models
        foundModel.set { customColors: true }, silent: true
        foundModel.set { colorFamily: colorFamilyObj }, silent: true

      # console.log foundModel

    # else
    #   console.log "No customColor match for product "+targetID+". Not in current product collection"

    return
