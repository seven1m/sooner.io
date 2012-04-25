#= require vendor/javascripts/jquery
#= require vendor/javascripts/underscore
#= require vendor/javascripts/backbone
#= require vendor/javascripts/backbone.iosync
#= require vendor/javascripts/backbone.iobind
#= require vendor/javascripts/bootstrap
#= require vendor/javascripts/date

#= require router

window.socket = io.connect()

window.jade = {} # hack to fix broken jade-browser

this.app ?= {}
this.app.models ?= {}
this.app.collections ?= {}
this.app.views ?= {}

class app.models.job extends Backbone.Model

class app.collections.jobs extends Backbone.Collection
  model: app.models.job
  url: 'job'

workspace = new app.router
Backbone.history.start pushState: yes
