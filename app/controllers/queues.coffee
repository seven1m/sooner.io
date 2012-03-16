models = require __dirname + '/../models'
dbInfo = require __dirname + '/../../lib/dbInfo'

module.exports =

  index: (req, res) ->
    dbInfo.listCollections (collections) ->
      queues = (q.replace(/^queue_/, '') for q in collections when q.match(/queue_/))
      res.render 'queues/index.jade',
        queues: queues
