#= require vendor/javascripts/jquery
#= require vendor/javascripts/underscore
#= require vendor/javascripts/backbone
#= require vendor/javascripts/backbone.iosync
#= require vendor/javascripts/backbone.iobind
#= require vendor/javascripts/bootstrap
#= require vendor/javascripts/date

#= require app
#= require router
#= require_tree models
#= require_tree collections
#= require_tree views

window.jade = {} # hack to fix broken jade-browser

$(document).ready ->
  app.start()