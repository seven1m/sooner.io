mongoose = require 'mongoose'
Schema = mongoose.Schema
models = require __dirname
cronJob = require('cron').CronJob

schema = new Schema
  name:
    type: String
    required: true
  schedule:
    type: String
    validate: (v) ->
      try
        new String(v).length > 0 && new cronJob(v)
      catch err
        console.log(err)
        false
  workerName:
    type: String
    default: 'worker'
  enabled:
    type: Boolean
    default: 'true'
  createdAt:
    type: Date
    default: -> new Date()
  lastRanAt:
    type: Date
  lastStatus:
    type: String
  definition:
    type: String

schema.methods.updateAttributes = (attrs) ->
  @name       = attrs.name
  @schedule   = attrs.schedule
  @workerName = attrs.workerName
  @enabled    = attrs.enabled == '1'
  @definition = attrs.definition

schema.methods.newRun = ->
  new models.run
    jobId:      @_id
    name:       @name
    definition: @definition

module.exports = mongoose.model 'Job', schema
