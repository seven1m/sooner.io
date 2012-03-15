Hook = require('hook.io').Hook
CronJob = require('cron').CronJob

argv = require('optimist')
       .usage("Start a worker process.\nUsage: $0")
       .alias('n', 'name')
       .describe('n', 'name this worker')
       .default('name', 'worker')
       .alias('h', 'host')
       .describe('h', 'host ip address; use own ip if this is to be the main worker process.')
       .default('host', '0.0.0.0')
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

GLOBAL.hook = hook = new Hook
  name: argv.name

hook.on '**::list-nodes', ->
  hook.emit 'i-am'
    name: hook.name
    host: hook['hook-host']
    port: hook['hook-port']

connDetails =
  'hook-host': argv.host
  'hook-port': argv.port

if argv.connect
  hook.connect connDetails
else
  hook.listen connDetails

# setup db
mongoose = require 'mongoose'
mongoose.connect "mongodb://#{argv.dbhost}/#{argv.dbname}"
models = require(__dirname + '/app/models')

# setup cron
crons = []
hook.on 'hook::ready', ->
  hook.on '**::reload-workflows', ->
    console.log 'loading workflows into cron...'
    cron.stop() for cron in crons
    models.workflow.find enabled: true, workerName: argv.name, (err, workflows) ->
      if err
        console.log 'error retrieving workflows'
      else
        console.log "workflows: #{JSON.stringify(w.name for w in workflows)}"
        for workflow in workflows
          cron = new CronJob workflow.schedule, ->
            job = workflow.newJob()
            job.save (err, job) ->
              hook.emit 'trigger-job', jobId: job._id, name: job.name
          crons.push cron
  hook.on '**::trigger-job', (data) ->
    models.job.findById data.jobId, (err, job) ->
      if err or !job
        console.log "Could not find job with id #{data.jobId}."
      else
        job.run()
  hook.emit 'reload-workflows'
