# Mustache style templates
_.templateSettings = interpolate: /\{\{(.+?)\}\}/g


# global variables
# Google Spreadsheet API uses the following params:
# - dataSource
# - dataSourceSheet
window.Vars = {
  env: 'production'
  debug: false
  rememberProduct: false
  dataSource: 'local'
  sheet_QA: 1
  sheet_Production: 2
  sheet_Dev: 3
  maxResult: 24
  results:
    active: 0
    total: 0
  headerFixedHeight: 281+86
  dataWaitMax: 10000
  url_img_placeholder: '//media.interface.com/is/image/InterfaceInc/logo_placeholder?$301x301$'
  url_scene7_tile: [
    '//media.interface.com/is/image/InterfaceInc/'
    '?wid=624&hei=624&align=-1,0&fit=crop'
  ]
  url_scene7_scene: [
    '//media.interface.com/ir/render/InterfaceIncRender/'
    '?&wid=960&hei=667&resmode=sharp2&qlt=80,1&obj=main&res=22.86&sharp=1&src=is{InterfaceInc/'
    '$tile=InterfaceInc/'
    '}'
  ]
  sizeMap:
    "5B": "50 cm x 50 cm"
    "5S": "50 cm x 50 cm"
    "1B": "1 m x 1 m"
    "7A": "25 cm x 1 m"
    "7B": "50 cm x 1m"
    "7C": "25 cm x 50 cm"
    "4B": "unknown"
    "3B": "unknown"
    "8S": "unknown"
    "7S": "25 cm x 1 m"

  configMap:
    "Ashlar" : "15"
    "Brick" : "25"
    "Monolithic" : "03"
    "Non-Directional" : "09"
    "Quarterturn" : "05"
    "Quarter-Turn" : "05"
    "Herringbone" : "29"

  colorData:[
    'Black'
    'Blue'
    'Brown/Tan'
    'Cream/Beige'
    'Green'
    'Grey'
    'Orange/Rust'
    'Purple'
    'Red/Pink'
    'Teal'
    'Yellow/Gold'
  ]

  user: {}
  authUser: {}
  compontentSetup: false
  failedImages: []
}


# toggle vars based on location
if location.hostname is 'localhost'
  Vars.env = 'dev'
  Vars.dataSourceSheet = Vars.sheet_QA if Vars.dataSource isnt 'local'

else if location.hostname is 'interface-carpet-sales.azurewebsites.net' or location.hostname is 'specials.interface.com' or location.hostname is 'interface-specials-framework.azurewebsites.net'
  if $('body').hasClass('admin')
    Vars.env = 'qa'
  else
    Vars.env = 'production'

else
  Vars.env = 'dev'
  Vars.dataSourceSheet = Vars.sheet_QA if Vars.dataSource isnt 'local'

# qa env always should use remote data and QA data sheet
if Vars.env is 'qa'
  Vars.dataSource = 'remote'
  Vars.dataSourceSheet = Vars.sheet_QA

if Vars.env is 'production'
  Vars.dataSource = 'remote'
  Vars.dataSourceSheet = Vars.sheet_Production


# setup backbone app vars
window.App = {}

# backbone structures for initializing new data sets
App.structure =
  model: {}
  collection: {}
  view: {}
  router: {}

# backbone format data
App.data =
  raw: {}
  products: {}

