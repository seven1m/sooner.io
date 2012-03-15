models = require __dirname + '/../models'

module.exports =

  show: (req, res) ->
    models.run.findById req.params.id, (err, run) ->
      if err
        res.send 'Not found', 404
      else
        res.render 'runs/show.jade',
          run: run

  create: (req, res) ->
    models.workflow.findById req.params.workflowId, (err, workflow) ->
      if err
        res.send 'Not found', 404
      else
        run = workflow.newRun()
        run.save (err, run) ->
          if err
            res.send 'Error creating run', 500
          else
            run.trigger()
            res.redirect("/runs/#{run._id}")
