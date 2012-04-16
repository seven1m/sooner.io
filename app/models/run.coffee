childProcess = require 'child_process'

util = require 'util'
_ = require 'underscore'
fs = require 'fs'

models = require __dirname
mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

scriptsDir = __dirname + '/../../scripts-working-copy'

model = null

schema = new Schema
  jobId:
    type: ObjectId
    required: true
    index: true
  name:
    type: String
  hooks:
    type: Array
  data:
    type: {}
  progress:
    type: [Number, Number]
    default: [0, 100]
  status:
    type: String
    enum: ['busy', 'idle', 'fail', 'success']
    default: 'idle'
  output:
    type: String
    default: ''
  result:
    type: Number
  createdAt:
    type: Date
    default: -> new Date()
  path:
    type: String
    required: true
  ranAt:
    type: Date
  completedAt:
    type: Date

schema.methods.fullPath = ->
  scriptsDir + '/' + @path

schema.methods.trigger = ->
  GLOBAL.hook.emit 'trigger-job', runId: @_id, jobId: @jobId, name: @name

# FIXME this is a mess
schema.methods.run = (callback) ->
  models.job.findById @jobId, (err, job) =>
    if err or !job then throw err
    try
      realPath = fs.realpathSync(@fullPath())
    catch e
      realPath = null
    if @path.trim() != '' and realPath
      # FIXME: there's a race condition here
      models.run.where('status', 'busy').where('jobId', @jobId).count (err, runningCount) =>
        if err then throw err

        if runningCount > 0 and job.mutex
          console.log 'Another run for this process already.'
          @status = 'fail'
          @output = 'another job is currently running'
          @ranAt = @completedAt = new Date()
          @save()
          GLOBAL.hook.emit 'running-job', runId: @_id, jobId: @jobId, name: @name, ranAt: @ranAt
          GLOBAL.hook.emit 'job-output', runId: @_id, jobId: @jobId, name: @name, output: @output
          GLOBAL.hook.emit 'job-status', runId: @_id, jobId: @jobId, name: @name, status: @status, ranAt: @ranAt, completedAt: @completedAt
          callback('another job already running')
        else
          @status = 'busy'
          @ranAt = new Date()
          @save()

          input = JSON.stringify(@data || {})
          child = childProcess.spawn @fullPath(), [input], {}
          GLOBAL.hook.emit 'running-job', pid: child.pid, runId: @_id, jobId: @jobId, name: @name, ranAt: @ranAt
          GLOBAL.hook.emit 'job-status', runId: @_id, jobId: @jobId, name: @name, status: @status, ranAt: @ranAt
          child.stdout.on 'data', (data) =>
            @output += data.toString()
            GLOBAL.hook.emit 'job-output', pid: child.pid, runId: @_id, jobId: @jobId, name: @name, output: data.toString()
            @save()
          child.stderr.on 'data', (data) =>
            @output += data.toString()
            GLOBAL.hook.emit 'job-output', pid: child.pid, runId: @_id, jobId: @jobId, name: @name, output: data.toString()
            @save()
          child.on 'exit', (code) =>
            @completedAt = new Date()
            @result = code
            if code == 0
              @status = 'success'
              @setProgress 'max'
            else
              @status = 'fail'
            GLOBAL.hook.emit 'job-status', runId: @_id, jobId: @jobId, name: @name, status: @status, result: @result.toString(), completedAt: @completedAt
            @save()
            job.lastStatus = @status
            job.lastRanAt = @ranAt
            job.save ->
              callback()
    else
      console.log 'could not find path'
      @output = 'could not find path'
      GLOBAL.hook.emit 'job-output', runId: @_id, jobId: @jobId, name: @name, output: @output
      @status = 'fail'
      GLOBAL.hook.emit 'job-status', runId: @_id, jobId: @jobId, name: @name, status: @status, completedAt: @completedAt
      @save()
      job.lastStatus = @status
      job.lastRanAt = @ranAt
      job.save ->
        callback('could not find path')

schema.methods.log = ->
  for arg in arguments
    if typeof arg in ['string', 'number']
      @output += new String(arg) + "\n"
    else
      @output += util.inspect(arg) + "\n"
  @save()

schema.methods.markFailed = ->
  @status = 'fail'
  @completedAt = new Date()
  @save (err) =>
    GLOBAL.hook.emit 'job-status', runId: @_id, jobId: @jobId, name: @name, status: @status

schema.methods.setProgress = (current, max, callback) ->
  if current == 'max'
    @progress[0] = @progress[1]
  else
    @progress[0] = current
    @progress[1] = max unless typeof max == 'undefined'
  @markModified 'progress'
  @save callback
  GLOBAL.hook.emit 'job-progress', runId: @_id, jobId: @jobId, name: @name, progress: @progress, progressPercent: @progressPercent()

schema.methods.progressPercent = ->
  try
    Math.min(100, @progress[0] / @progress[1] * 100)
  catch e
    0

module.exports = model = mongoose.model 'Run', schema
