_ = require 'underscore'
models = require __dirname + '/../models'
dbInfo = require __dirname + '/../../lib/dbInfo'
Paginator = require 'paginator'

context = {}
require(__dirname + '/../../lib/sandbox/queue').init(context)

module.exports =

  index: (req, res) ->
    dbInfo.listCollections (collections) ->
      queues = (q.replace(/^queue_/, '') for q in collections when q.match(/queue_/))
      res.render 'queues/index.jade',
        queues: queues

  show: (req, res) ->
    try
      query = JSON.parse(req.query.query || '{}')
      badQuery = false
    catch e
      query = {}
      badQuery = true
    q = context.queue(req.params.id).find(query)
    _.clone(q).count (err, count) ->
      if err then throw err
      paginator = new Paginator perPage: 50, page: req.query.page, count: count
      q.skip(paginator.skip).limit(paginator.limit).desc('createdAt').run (err, entries) ->
        if err
          entries = []
        res.render 'queues/show.jade',
          query: req.query.query || '{}'
          badQuery: badQuery
          count: count
          queue: req.params.id
          entries: entries
          paginator: paginator
