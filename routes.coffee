controllers = require './app/controllers'

module.exports = (app) ->
  app.resource '/', controllers.home
