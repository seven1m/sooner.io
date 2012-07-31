mongoose = require 'mongoose'
Schema = mongoose.Schema
models = require __dirname
CronJob = require('cron').CronJob
_ = require 'underscore'

schema = new Schema
  name:
    type: String
    required: true
  schedule:
    type: String
    validate: (v) ->
      try
        new String(v).length == 0 || new CronJob(v)
      catch err
        console.log(err)
        false
  hooks:
    type: String
    trim: true
  workerName:
    type: String
    default: 'worker'
    index: true
  enabled:
    type: Boolean
    default: 'true'
    index: true
  createdAt:
    type: Date
    default: -> new Date()
  updatedAt:
    type: Date
  lastRanAt:
    type: Date
  lastStatus:
    type: String
  path:
    type: String
    required: true
  mutex:
    type: Boolean
    default: true
  report:
    type: Boolean
    required: true
    default: false
  deleted:
    type: Boolean
    default: false

schema.pre 'save', (next) ->
  if !@createdAt
    @createdAt = @updatedAt = new Date()
  else
    @updatedAt = new Date()
  next()

schema.methods.updateAttributes = (attrs) ->
  @name       = attrs.name
  @schedule   = attrs.schedule
  @enabled    = attrs.enabled == '1'
  @mutex      = attrs.mutex == '1'
  @hooks      = attrs.hooks
  @workerName = attrs.workerName

schema.methods.newRun = ->
  new models.run
    jobId:      @_id
    name:       @name
    path:       @path
    workerName: @workerName
    report:     @report
    data:       ''

schema.methods.newCron = ->
  new CronJob @schedule, =>
    run = @newRun()
    run.save (err, run) ->
      if err
        console.log err
      else
        GLOBAL.hook.emit 'sync::refresh::job', _id: run.jobId
        GLOBAL.hook.emit 'sync::trigger::run', _id: run._id, name: run.name

schema.methods.hookEvent = (hook, data) ->
  console.log "#{@name} triggered by event '#{hook}' with data #{data}"
  run = @newRun()
  run.data = data.toString() if data
  run.save (err, run) ->
    if err then throw err
    GLOBAL.hook.emit 'sync::refresh::job', _id: run.jobId
    GLOBAL.hook.emit 'sync::trigger::run', _id: run._id, name: run.name

module.exports = model = mongoose.model 'Job', schema

model.sync = (socket) ->
  name = @modelName.toLowerCase()

  readJob = (data, report, callback) =>
    if id = (data._id || data.id)
      @findOne _id: id, deleted: false, report: report, callback
    else
      @find deleted: false, report: report, callback

  socket.on 'sync::read::job', (data, callback) =>
    readJob data, false, callback

  socket.on 'sync::read::report', (data, callback) =>
    readJob data, true, callback

  socket.on 'sync::update::job', (data, callback) =>
    @findById data._id || data.id, (err, job) =>
      if err or not job
        callback err || 'job not found'
      else
        for attr in ['name', 'enabled', 'schedule', 'hooks', 'workerName', 'mutex']
          job[attr] = data[attr] if data[attr]?
        job.save (err) =>
          if err
            callback err
          else
            GLOBAL.hook.emit 'sync::refresh::job', _id: job.id
            GLOBAL.hook.emit 'worker::reload::jobs'
            callback null, job

  socket.on 'sync::update::report', (data, callback) =>
    @findById data._id || data.id, (err, report) =>
      if err or not report
        callback err || 'report not found'
      else
        for attr in ['name', 'workerName']
          report[attr] = data[attr] if data[attr]?
        report.save (err) =>
          if err
            callback err
          else
            GLOBAL.hook.emit 'sync::refresh::report', _id: report.id
            GLOBAL.hook.emit 'worker::reload::reports'
            callback null, report

