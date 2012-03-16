#!/usr/bin/env coffee

vm = require 'vm'
fs = require 'fs'
CoffeeScript = require 'coffee-script'

config = JSON.parse(fs.readFileSync(__dirname + '/../config.json'))

mongoose = require 'mongoose'
mongoose.connect "mongodb://#{config.db.host}/#{config.db.name}"

# objects to which we're willing to give access
buildContext = ->
  context =
    console: log: console.log
    setTimeout: setTimeout
    clearTimeout: clearTimeout
    setInterval: setInterval
    clearInterval: clearInterval
    done: -> mongoose.disconnect()
  # load in the other libs
  for file in fs.readdirSync(__dirname + '/sandbox')
    if file.match(/\.coffee$/)
      name = file.substr 0, file.indexOf('.')
      require(__dirname + '/sandbox/' + name).init(context, config)
  context

code = fs.readFileSync('/dev/stdin').toString()
js = CoffeeScript.compile code
vm.runInNewContext js, buildContext(), 'sandbox.vm'
