#!/usr/bin/env coffee

vm = require 'vm'
fs = require 'fs'
_ = require 'underscore'
CoffeeScript = require 'coffee-script'

config = JSON.parse(fs.readFileSync(__dirname + '/../config.json'))

mongoose = require 'mongoose'
mongoose.connect config.db

EventEmitter2Mongo = require __dirname + '/eventemitter2mongo'
GLOBAL.hook = hook = new EventEmitter2Mongo config.db, delimiter: '::'

models = require __dirname + '/../app/models'

# objects to which we're willing to give access
buildContext = (input, callback) ->
  models.run.findById input.runId, (err, run) ->
    if err then throw err
    if !run then throw 'Job run not found.'
    context =
      jobId: input.jobId
      runId: input.runId
      data: input.data
      bind: _.bind
      console: log: console.log
      setTimeout: setTimeout
      clearTimeout: clearTimeout
      setInterval: setInterval
      clearInterval: clearInterval
      emit: _.bind(hook.emit, hook)
      progress: _.bind(run.setProgress, run)
      done: ->
        run.setProgress 'max', null, (err) ->
          setTimeout ->
            hook.disconnect()
            mongoose.disconnect()
          , 50
    # load in the other libs
    for file in fs.readdirSync(__dirname + '/sandbox')
      if file.match(/\.coffee$/)
        name = file.substr 0, file.indexOf('.')
        require(__dirname + '/sandbox/' + name).init(context, config)
    callback context

input = JSON.parse(fs.readFileSync('/dev/stdin').toString())
js = CoffeeScript.compile input.code
buildContext input, (context) ->
  vm.runInNewContext js, context, 'sandbox.vm'
