EventEmitter2Mongo = require(__dirname + '/eventemitter2mongo')
_ = require('underscore')
fs = require('fs')
iam = require(__dirname + '/iam')
mongoose = require('mongoose')
models = require(__dirname + '/../models')

class Worker
  constructor: (@opts) ->
    console.log "Starting \"#{@opts.name}\" worker..."
    @cache =
      crons: []
      hooks: []
    @setupDB()
    @setupHook()
    @cleanUp()
    @watchExit()

  setupDB: =>
    @config = JSON.parse(fs.readFileSync(@opts.config))
    mongoose.connect @config.db

  setupHook: =>
    @hook = new EventEmitter2Mongo @config.db, delimiter: '::'
    GLOBAL.hook ||= @hook
    @hook.name = @opts.name
    @hook.on 'ready', @loadJobs
    @hook.on 'sync::trigger::run', @triggerJob
    @hook.on 'worker::reload::jobs', @loadJobs
    @hook.on 'sync::stop::run', @stopRun
    iam.setup(@hook)
    if @opts.debug then @hook.on '**', (data) => console.log 'DEBUG>>>', @hook.event, data || ''
    @hook.emit 'cxn::connected'

  cleanUp: =>
    models.run.where('status').in(['busy', 'idle']).where('workerName', @hook.name).run (err, runs) =>
      if err
        console.log "Too many failed runs... marking them all failed."
        models.run.update {status: {$in: ['busy', 'idle']}}, {$set: {status: 'fail'}}, {multi: true}, (err) ->
          if err then throw err
      else
        console.log "Found #{runs.length} run(s) in limbo."
        run.fail('stuck running during restart') for run in runs

  loadJobs: =>
    console.log 'loading jobs...'
    @tearDownJobs()
    models.job.find workerName: @hook.name, enabled: true, (err, jobs) =>
      console.log "jobs found: #{JSON.stringify(j.name for j in jobs)}"
      for job in jobs
        if job.schedule and job.schedule.trim() != ''
          console.log "setting up cron '#{job.schedule}' for #{job.name}."
          @cache.crons.push [job.newCron(), job]
        if job.hooks and job.hooks.trim() != ''
          for event in job.hooks.trim().split(/\s*,\s*/)
            @setupJobHook event, job

  setupJobHook: (event, job) =>
    console.log "setting up hook '#{event}' for #{job.name}."
    cb = (data) -> job.hookEvent(this.event, data)
    @hook.on event, cb
    @cache.hooks.push [event, cb, job]

  tearDownJobs: =>
    for [cron, job] in @cache.crons
      console.log "tearing down cron '#{job.schedule}' for #{job.name}."
      cron.stop()
    for [ev, cb, job] in @cache.hooks
      console.log "tearing down hook '#{ev}' for #{job.name}."
      @hook.off(ev, cb)
    @cache =
      crons: []
      hooks: []

  triggerJob: (data) =>
    models.run.findOne _id: data.id || data._id, workerName: @hook.name, (err, run) =>
      if err or !run
        console.log "Could not find run with id #{data.runId}."
      else
        console.log "running: #{run.name}"
        run.run =>
          console.log "complete: #{run.name}"

  stopRun: (data) =>
    models.run.findOne _id: data.id || data._id, workerName: @hook.name, (err, run) =>
      if !err and run
        console.log "stopping: #{run.name} run #{run._id}"
        run.stop('user')

  watchExit: =>
    process.on 'SIGINT', =>
      @hook.emit 'cxn::disconnected'
      process.exit()

module.exports = Worker
