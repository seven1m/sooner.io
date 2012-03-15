controllers = require './app/controllers'

module.exports = (app) ->
  app.get '/', (_, res) -> res.redirect('/jobs')
  app.resources '/jobs', controllers.jobs
  app.resources '/runs', controllers.runs
  app.post '/jobs/:jobId/runs', controllers.runs.create
  app.resource '/status', controllers.status
