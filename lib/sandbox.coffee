#!/usr/bin/env coffee

vm = require 'vm'
fs = require 'fs'
CoffeeScript = require 'coffee-script'

config = JSON.parse(fs.readFileSync(__dirname + '/../config.json'))

mongoose = require 'mongoose'
mongoose.connect "mongodb://#{config.db.host}/#{config.db.name}"
models = require __dirname + '/../app/models'

# objects to which we're willing to give access
buildContext = ->
  context =
    console: log: console.log
  # load in the other libs
  for file in fs.readdirSync(__dirname + '/sandbox')
    if file.match(/\.coffee$/)
      name = file.substr 0, file.indexOf('.')
      require(__dirname + '/sandbox/' + name).init(context, config)
  context

models.job.findById process.argv[2], (err, job) ->
  if err
    mongoose.disconnect()
    throw err
  else if job
    js = CoffeeScript.compile job.definition
    vm.runInNewContext js, buildContext(), 'sandbox.vm'
    mongoose.disconnect()
  else
    console.log "Error: job not found"
    mongoose.disconnect()
    process.exit(1)
