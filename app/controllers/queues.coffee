models = require __dirname + '/../models'
dbInfo = require __dirname + '/../../lib/dbInfo'
Paginator = require __dirname + '/../../lib/paginator'

context = {}
require(__dirname + '/../../lib/sandbox/queue').init(context)

module.exports =

  index: (req, res) ->
    dbInfo.listCollections (collections) ->
      queues = (q.replace(/^queue_/, '') for q in collections when q.match(/queue_/))
      res.render 'queues/index.jade',
        queues: queues

  show: (req, res) ->
    q = context.queue(req.params.id).where()
    if req.query.status
      q = q.where('status', req.query.status)
    new Paginator perPage: 50, page: req.query.page, query: q, (paginator) ->
      q.skip(paginator.skip).limit(paginator.limit).desc('createdAt').run (err, entries) ->
        if err
          entries = []
        res.render 'queues/show.jade',
          queue: req.params.id
          entries: entries
          paginator: paginator
