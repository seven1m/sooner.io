#= require vendor/jquery
#= require vendor/underscore
#= require vendor/backbone
#= require vendor/modelbinder
#= require vendor/backbone.queryparams
#= require vendor/bootstrap
#= require vendor/date

#= require lib/sync
#= require app
#= require config/formats
#= require lib/paginator
#= require lib/bound_view
#= require lib/paginated_collection
#= require lib/computed_attributes
#= require lib/converters
#= require router
#= require_tree models
#= require_tree collections
#= require_tree views
#= require_tree helpers

window.jade = {} # hack to fix broken jade-browser

$(document).ready ->
  app.start()
