EventEmitter2Mongo = require(__dirname + '/eventemitter2mongo')
_ = require('underscore')
fs = require('fs')
iam = require(__dirname + '/iam')
mongo = require('mongodb')

class Watcher
  constructor: (@opts) ->
    console.log "Starting \"#{@opts.name}\" watcher..."
    @config = JSON.parse(fs.readFileSync(@opts.config))
    @setupHook()
    @setupWatchers()
    @watchExit()

  setupHook: =>
    @hook = new EventEmitter2Mongo @config.db, delimiter: '::'
    GLOBAL.hook ||= @hook
    @hook.name = @opts.name
    iam.setup(@hook)
    if @opts.debug then @hook.on '**', (data) => console.log 'DEBUG>>>', @hook.event, data || ''
    @hook.emit 'cxn::connected'

  setupWatchers: (callback) =>
    @watchers = []
    for watch in @config.watchers
      @watchCollection(watch) if watch.name == @opts.name

  watchCollection: (watch) =>
    console.log "Setting up watcher for #{watch.db}/#{watch.collection} every #{watch.frequency} milliseconds..."
    mongo.connect watch.db, (err, db) =>
      if err then throw err
      db.collection watch.collection, (err, collection) =>
        if err then throw err
        @pollCollection watch, collection
        setInterval _.bind(@pollCollection, @, watch, collection), watch.frequency

  pollCollection: (watch, collection) =>
    if watch.last_id
      query = {_id: {$gt: watch.last_id}}
      limit = 10000
      sort = {_id: 1}
    else
      query = {}
      limit = 1
      sort = {_id: -1}
    collection.find(query, {_id: 1}).sort(sort).limit(limit).toArray (err, results) =>
      if @opts.debug then console.log "polling #{watch.collection}..."
      if results.length > 0
        if watch.last_id? # not first time
          ids = (r._id for r in results)
          console.log "Emitting #{watch.hook} with:", ids
          @hook.emit watch.hook, ids
        watch.last_id = results[results.length-1]._id

  watchExit: =>
    process.on 'SIGINT', =>
      @hook.emit 'cxn::disconnected'
      process.exit()

module.exports = Watcher
