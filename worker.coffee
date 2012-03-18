Hook = require('hook.io').Hook
fs = require "fs"
ifaces = require(__dirname + '/lib/ip').ifaces

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
       .argv

GLOBAL.hook = hook = new Hook
  name: argv.name

hook.on '**::list-nodes', ->
  hook.emit 'i-am'
    name: hook.name
    host: ifaces().join(', ')
    port: hook['hook-port']

connDetails =
  'hook-host': argv.host
  'hook-port': argv.port

if argv.connect
  hook.connect connDetails
else
  hook.listen connDetails

# setup db
config = JSON.parse(fs.readFileSync(__dirname + '/config.json'))
mongoose = require 'mongoose'
mongoose.connect "mongodb://#{config.db.host}/#{config.db.name}"
models = require(__dirname + '/app/models')

# clean up
models.run.find {status: 'busy'}, (err, runs) ->
  console.log "Searching for runs in limbo..."
  if err then throw err
  for run in runs
    console.log "...marking run #{run._id} as failed."
    run.status = 'fail'
    run.completedAt = new Date()
    run.save (err) ->
      if err then throw err
      hook.emit 'job-complete', runId: run._id, jobId: run.jobId, name: run.name, status: run.status
  if runs.length == 0
    console.log "...none found."

# setup cron
crons = []
hook.on 'hook::ready', ->
  hook.on '**::reload-jobs', ->
    console.log 'loading jobs into cron...'
    cron.stop() for cron in crons
    models.job.find enabled: true, workerName: argv.name, (err, jobs) ->
      if err
        console.log 'error retrieving jobs'
      else
        console.log "jobs: #{JSON.stringify(w.name for w in jobs)}"
        for job in jobs
          crons.push job.newCron()
  hook.on '**::trigger-job', (data) ->
    models.run.findById data.runId, (err, run) ->
      if err or !run
        console.log "Could not find run with id #{data.runId}."
      else
        run.run()
  hook.emit 'reload-jobs'
