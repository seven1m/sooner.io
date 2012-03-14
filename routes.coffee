controllers = require './app/controllers'

module.exports = (app) ->
  app.get '/', (_, res) -> res.redirect('/workflows')
  app.resources '/workflows', controllers.workflows
  app.resource '/status', controllers.status
