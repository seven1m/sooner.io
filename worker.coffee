EventEmitter2Mongo = require __dirname + '/lib/eventemitter2mongo'
_ = require "underscore"
fs = require "fs"
ifaces = require(__dirname + '/lib/ip').ifaces

opts = require('optimist').usage("Start a worker process.\nUsage: $0")
       .describe('name', 'name this worker').default('name', 'worker').alias('n', 'name')
argv = opts.argv

if argv.help
  console.log opts.help()
  process.exit()

# setup db
config = JSON.parse(fs.readFileSync(__dirname + '/config.json'))
mongoose = require 'mongoose'
mongoose.connect "mongodb://#{config.db.host}/#{config.db.name}"
models = require(__dirname + '/app/models')

GLOBAL.hook = hook = new EventEmitter2Mongo config.db.host, config.db.port || 27017, config.db.name, delimiter: '::'
hook.name = argv.name

hook.on 'list-nodes', ->
  hook.emit 'i-am'
    name: hook.name
    host: ifaces().join(', ')

# clean up
models.run.find {status: 'busy', workerName: hook.name}, (err, runs) ->
  console.log "Searching for runs in limbo..."
  if err then throw err
  for run in runs
    console.log "...marking run #{run._id} as failed."
    run.status = 'fail'
    run.completedAt = new Date()
    run.save (err) ->
      if err then throw err
      hook.emit 'job-status', runId: run._id, jobId: run.jobId, name: run.name, status: run.status
  if runs.length == 0
    console.log "...none found."

jobCache =
  crons: []
  hooks: []

hook.on 'ready', ->
  reloadJobs = ->
    console.log 'loading jobs...'
    cron.stop() for cron in jobCache.crons
    hook.off.apply(this, h) for h in jobCache.hooks

    models.job.find workerName: hook.name, (err, jobs) ->
      if err
        console.log 'error retrieving jobs'
      else
        console.log "jobs: #{JSON.stringify(j.name for j in jobs)}"
        for job in jobs
          if job.enabled
            console.log "setting up cron for #{job.name}."
            jobCache.crons.push job.newCron()
          if job.hooks and job.hooks != ''
            for event in job.hooks.split(/\s*,\s*/)
              console.log "setting up hook #{event} for #{job.name}."
              cb = _.bind(job.hookEvent, job)
              hook.on event, cb
              jobCache.hooks.push [event, cb]

  jobTriggered = (data) ->
    models.run.findOne _id: data.runId, workerName: hook.name, (err, run) ->
      if err or !run
        console.log "Could not find run with id #{data.runId}."
      else
        run.run()
  hook.on 'trigger-job', (data) -> _.delay jobTriggered, 1500, data
  hook.on 'reload-jobs', reloadJobs
  reloadJobs()

  hook.emit 'connected'

  process.on 'uncaughtException', (err) ->
    try
      hook.emit 'disconnected'
    catch e
      # pass
    throw err

  process.on 'SIGINT', ->
    hook.emit 'disconnected'
    process.exit()
