_ = require 'underscore'
models = require __dirname + '/../models'
dbInfo = require __dirname + '/../../lib/dbInfo'
Paginator = require 'paginator'

module.exports =

  index: (req, res) ->
    dbInfo.listCollections (collections) ->
      queues = (q.replace(/^queue_/, '') for q in collections when q.match(/queue_/))
      res.render 'queues/index.jade',
        queues: queues

  show: (req, res) ->
    @setQueryAndSort(req)
    q = models.queue(req.params.id).find(@dataQuery)
    q = q.sort.apply(q, @dataSort)
    _.clone(q).count (err, count) =>
      if err then throw err
      paginator = new Paginator perPage: 5, page: req.query.page, count: count
      q.skip(paginator.skip).limit(paginator.limit).run (err, entries) =>
        if err
          entries = []
        res.render 'queues/show.jade',
          query: JSON.stringify(@dataQuery)
          sort: JSON.stringify(@dataSort)
          badQuery: @badQuery
          count: count
          queue: req.params.id
          entries: entries
          paginator: paginator

  setQueryAndSort: (req) ->
    try
      @dataQuery = JSON.parse(req.query.query || '{}')
      @dataSort = JSON.parse(req.query.sort || '["updatedAt", -1]')
      @badQuery = false
    catch e
      @dataQuery = {}
      @dataSort = ['updatedAt', -1]
      @badQuery = true
