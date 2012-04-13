EventEmitter2Mongo = require(__dirname + '/eventemitter2mongo')
_ = require('underscore')
fs = require('fs')
iam = require(__dirname + '/iam')
mongoose = require('mongoose')
models = require(__dirname + '/../app/models')

class Worker
  startDelay: 2500

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
    @hook.on 'trigger-job', (data) =>
      _.delay(@triggerJob, @startDelay, data)
    @hook.on 'reload-jobs', @loadJobs
    iam.setup(@hook)
    if @opts.debug then @hook.on '*', (data) => console.log @hook.event, data || ''
    @hook.emit 'connected'

  cleanUp: =>
    models.run.find {status: {$in: ['busy', 'idle']}, workerName: @hook.name}, (err, runs) =>
      console.log "Found #{runs.length} run(s) in limbo."
      run.markFailed() for run in runs

  loadJobs: =>
    console.log 'loading jobs...'
    cron.stop() for cron in @cache.crons
    @hook.off.apply(this, h) for h in @cache.hooks

    models.job.find workerName: @hook.name, (err, jobs) =>
      console.log "jobs found: #{JSON.stringify(j.name for j in jobs)}"
      for job in jobs
        if job.enabled
          console.log "setting up cron for #{job.name}."
          @cache.crons.push job.newCron()
        if job.hooks and job.hooks != ''
          for event in job.hooks.split(/\s*,\s*/)
            console.log "setting up hook #{event} for #{job.name}."
            cb = _.bind(job.hookEvent, job)
            @hook.on event, cb
            @cache.hooks.push [event, cb]

  triggerJob: (data) =>
    models.run.findOne _id: data.runId, workerName: @hook.name, (err, run) =>
      if err or !run
        console.log "Could not find run with id #{data.runId}."
      else
        console.log "running: #{run.name}"
        run.run =>
          console.log "complete: #{run.name}"

  watchExit: =>
    process.on 'uncaughtException', (err) =>
      try
        @hook.emit 'disconnected'
      catch e
        # pass
      throw err

    process.on 'SIGINT', =>
      @hook.emit 'disconnected'
      process.exit()

module.exports = Worker
