models = require __dirname + '/../models'

module.exports =

  show: (req, res) ->
    res.render 'status/show.jade'
