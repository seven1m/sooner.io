mongoose = require 'mongoose'
Schema = mongoose.Schema
models = require __dirname
CronJob = require('cron').CronJob

VALID_EVENTS = /^fs::/

schema = new Schema
  name:
    type: String
    required: true
  schedule:
    type: String
    validate: (v) ->
      try
        new String(v).length > 0 && new CronJob(v)
      catch err
        console.log(err)
        false
  hooks:
    type: String
    trim: yes
    validate: (v) ->
      all = new String(v).split(/\s*,\s*/)
      for hook in all
        return false unless hook == '' or hook.match(VALID_EVENTS)
      true
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
  lastRanAt:
    type: Date
  lastStatus:
    type: String
  definition:
    type: String
  mutex:
    type: Boolean
    default: true

schema.methods.updateAttributes = (attrs) ->
  @name       = attrs.name
  @schedule   = attrs.schedule
  @enabled    = attrs.enabled == '1'
  @mutex      = attrs.mutex == '1'
  @hooks      = attrs.hooks
  @workerName = attrs.workerName
  @definition = attrs.definition

schema.methods.newRun = ->
  new models.run
    jobId:      @_id
    name:       @name
    definition: @definition
    workerName: @workerName

schema.methods.newCron = ->
  new CronJob @schedule, =>
    run = @newRun()
    run.save (err, run) ->
      GLOBAL.hook.emit 'trigger-job', runId: run._id, name: run.name

schema.methods.hookEvent = (data) ->
  run = @newRun()
  run.data = data
  run.save (err, run) ->
    GLOBAL.hook.emit 'trigger-job', runId: run._id, name: run.name

module.exports = mongoose.model 'Job', schema
