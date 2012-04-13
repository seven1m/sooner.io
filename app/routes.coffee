controllers = require __dirname + '/controllers'

module.exports = (app) ->
  app.get '/', (_, res) -> res.redirect('/jobs')
  app.resources '/jobs', controllers.jobs
  app.resources '/runs', controllers.runs
  app.resources '/queues', controllers.queues
  app.post '/jobs/:jobId/runs', controllers.runs.create
  app.resource '/status', controllers.status
