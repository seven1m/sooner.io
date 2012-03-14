Hook = require('hook.io').Hook
CronJob = require('cron').CronJob
vm = require('vm')

argv = require('optimist')
       .usage("Start a worker process.\nUsage: $0")
       .alias('n', 'name')
       .describe('n', 'name this worker')
       .default('name', 'worker')
       .demand('h')
       .alias('h', 'host')
       .describe('h', 'host ip address; use own ip if this is to be the main worker process.')
       .alias('p', 'port')
       .describe('p', 'host port')
       .default('port', 5000)
       .alias('c', 'connect')
       .describe('c', 'connect to a remote host (use this option if not the server)')
       .describe('dbhost', 'host running mongodb database')
       .default('dbhost', 'localhost')
       .describe('dbname', 'name of mongodb database')
       .default('dbname', 'boomer-sooner')
       .argv

hook = new Hook
  name: argv.name
  "hook-host": argv.host
  "hook-port": argv.port

if argv.connect
  hook.connect()
else
  hook.listen()

# setup db
mongoose = require 'mongoose'
mongoose.connect "mongodb://#{argv.dbhost}/#{argv.dbname}"
models = require(__dirname + '/app/models')

# setup cron
crons = []
hook.on 'hook::ready', ->
  hook.on '**::reload-workflows', ->
    console.log 'loading workflows into cron...'
    job.stop() for job in crons
    models.workflow.find enabled: true, workerName: argv.name, (err, workflows) ->
      if err
        console.log 'error retrieving workflows'
      else
        console.log "workflows: #{JSON.stringify(w.name for w in workflows)}"
        for workflow in workflows
          job = new CronJob workflow.schedule, ->
            console.log "running #{workflow.name}..."
          crons.push job
  hook.emit 'reload-workflows'

# start of basic sandboxing
try
  context =
    console: console
  vm.runInNewContext('console.log(13)', context, 'sandbox.vm')
catch err
  console.log(err)
