models = require __dirname + '/../models'

module.exports =

  show: (req, res) ->
    models.workflow.find {}, (err, workflows) ->
      if(err)
        res.send('error retreiving workflows', 500)
      else
        res.render 'home/show.jade',
          title: 'Boomer Sooner'
          workflows: workflows
