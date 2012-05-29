EventEmitter2Mongo = require(__dirname + '/eventemitter2mongo')
_ = require('underscore')
fs = require('fs')
iam = require(__dirname + '/iam')
mongoose = require('mongoose')
models = require(__dirname + '/../models')

class Listener
  constructor: (@opts) ->
    console.log "Starting \"#{@opts.name}\" listener..."
    @setupDB()
    @foobar
    @watchExit()

  foobar: ->
    # given options, connect to mongo with a tailable cursor (example: EventEmitter2Mongo)
    # emit events based on results from cursor

  setupDB: =>
    @config = JSON.parse(fs.readFileSync(@opts.config))
    mongoose.connect @config.db

  watchExit: =>
    process.on 'SIGINT', =>
      @hook.emit 'cxn::disconnected'
      process.exit()

module.exports = Worker
