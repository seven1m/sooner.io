models = require __dirname + '/../models'

module.exports =

  show: (req, res) ->
    models.job.findById req.params.id, (err, job) ->
      if err
        res.send 'Not found', 404
      else
        res.render 'jobs/show.jade',
          job: job

  create: (req, res) ->
    models.workflow.findById req.params.workflowId, (err, workflow) ->
      if err
        res.send 'Not found', 404
      else
        job = workflow.newJob()
        job.save (err, job) ->
          if err
            res.send 'Error creating job', 500
          else
            job.trigger()
            res.redirect("/jobs/#{job._id}")
