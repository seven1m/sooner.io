controllers = require './app/controllers'

module.exports = (app) ->
  app.get '/', (_, res) -> res.redirect('/workflows')
  app.resources '/workflows', controllers.workflows
  app.resources '/jobs', controllers.jobs
  app.post '/workflows/:workflowId/jobs', controllers.jobs.create
  app.resource '/status', controllers.status
