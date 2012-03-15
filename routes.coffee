controllers = require './app/controllers'

module.exports = (app) ->
  app.get '/', (_, res) -> res.redirect('/workflows')
  app.resources '/workflows', controllers.workflows
  app.resources '/runs', controllers.runs
  app.post '/workflows/:workflowId/runs', controllers.runs.create
  app.resource '/status', controllers.status
