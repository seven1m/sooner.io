models = require __dirname + '/../models'

module.exports =

  index: (req, res) ->
    models.workflow.find {}, (err, workflows) ->
      if(err)
        res.send('error retreiving workflows', 500)
      else
        res.render 'workflows/index.jade',
          workflows: workflows

  show: (req, res) ->
    models.workflow.findOne {_id: req.params.id}, (err, workflow) ->
      if err
        res.send 'Not found', 404
      else
        res.render 'workflows/show.jade',
          workflow: workflow

  new: (req, res) ->
    workflow = new models.workflow()
    res.render 'workflows/new.jade',
      workflow: workflow

  create: (req, res) ->
    workflow = new models.workflow(req.body)
    workflow.save (err) ->
      if err
        workflow.errors = err.errors
        res.render 'workflows/new.jade',
          workflow: workflow
      else
        res.redirect("/workflows/#{workflow._id}")

  edit: (req, res) ->
    models.workflow.findOne {_id: req.params.id}, (err, workflow) ->
      if err
        res.send 'Not found', 404
      else
        res.render 'workflows/edit.jade',
          workflow: workflow

  update: (req, res) ->
    models.workflow.findOne {_id: req.params.id}, (err, workflow) ->
      if err
        res.send 'Not found', 404
      else
        workflow[attr] = req.body[attr] for attr of req.body
        workflow.save (err) ->
          if err
            workflow.errors = err.errors
            res.render 'workflows/edit.jade',
              workflow: workflow
          else
            res.redirect("/workflows/#{workflow._id}")

  delete: (req, res) ->
    models.workflow.remove {_id: req.params.id}, (err) ->
      if err
        res.send err, 404
      else
        res.redirect("/workflows")
