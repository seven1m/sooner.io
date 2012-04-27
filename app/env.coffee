#= require vendor/javascripts/jquery
#= require vendor/javascripts/underscore
#= require vendor/javascripts/backbone
#= require vendor/javascripts/modelbinder
#= require vendor/javascripts/bootstrap
#= require vendor/javascripts/date

#= require ext
#= require app
#= require router
#= require sync
#= require formats
#= require converters
#= require_tree models
#= require_tree collections
#= require_tree views
#= require_tree helpers

window.jade = {} # hack to fix broken jade-browser

$(document).ready ->
  app.start()
