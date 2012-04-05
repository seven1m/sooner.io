#!/usr/bin/env coffee

vm = require 'vm'
fs = require 'fs'
_ = require 'underscore'
CoffeeScript = require 'coffee-script'

config = JSON.parse(fs.readFileSync(__dirname + '/../config.json'))

mongoose = require 'mongoose'
mongoose.connect config.db

EventEmitter2Mongo = require __dirname + '/eventemitter2mongo'
hook = new EventEmitter2Mongo config.db, delimiter: '::'

# objects to which we're willing to give access
buildContext = (data) ->
  context =
    data: data
    bind: _.bind
    console: log: console.log
    setTimeout: setTimeout
    clearTimeout: clearTimeout
    setInterval: setInterval
    clearInterval: clearInterval
    emit: _.bind(hook.emit, hook)
    done: ->
      setTimeout ->
        hook.disconnect()
        mongoose.disconnect()
      , 50
  # load in the other libs
  for file in fs.readdirSync(__dirname + '/sandbox')
    if file.match(/\.coffee$/)
      name = file.substr 0, file.indexOf('.')
      require(__dirname + '/sandbox/' + name).init(context, config)
  context

input = JSON.parse(fs.readFileSync('/dev/stdin').toString())
js = CoffeeScript.compile input.code
vm.runInNewContext js, buildContext(input.data || {}), 'sandbox.vm'
