childProcess = require 'child_process'

util = require 'util'
_ = require 'underscore'

models = require __dirname
mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

schema = new Schema
  jobId:
    type: ObjectId
    required: true
    index: true
  name:
    type: String
  definition:
    type: String
  hooks:
    type: Array
  data:
    type: {}
  status:
    type: String
    enum: ['busy', 'idle', 'fail', 'success']
    default: 'idle'
  output:
    type: String
    default: ''
  result:
    type: String
  createdAt:
    type: Date
    default: -> new Date()
  ranAt:
    type: Date
  completedAt:
    type: Date

schema.methods.trigger = ->
  GLOBAL.hook.emit 'trigger-job', runId: @_id, jobId: @jobId, name: @name

schema.methods.run = ->
  console.log "running #{@name}..."
  models.job.findById @jobId, (err, job) =>
    if err or !job then throw err
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
      else
        @status = 'busy'
        @ranAt = new Date()
        @save()
        GLOBAL.hook.emit 'job-status', runId: @_id, jobId: @jobId, name: @name, status: @status, ranAt: @ranAt

        input =
          code: @definition
          data: @data || {}
        sandbox = childProcess.spawn "coffee", ["#{__dirname}/../../lib/sandbox.coffee"], {}
        sandbox.stdin.end JSON.stringify(input)
        GLOBAL.hook.emit 'running-job', pid: sandbox.pid, runId: @_id, jobId: @jobId, name: @name, ranAt: @ranAt
        sandbox.stdout.on 'data', (data) =>
          @output += data.toString()
          GLOBAL.hook.emit 'job-output', pid: sandbox.pid, runId: @_id, jobId: @jobId, name: @name, output: data.toString()
          @save()
        sandbox.stderr.on 'data', (data) =>
          @output += data.toString()
          GLOBAL.hook.emit 'job-output', pid: sandbox.pid, runId: @_id, jobId: @jobId, name: @name, output: data.toString()
          @save()
        sandbox.on 'exit', (code) =>
          @completedAt = new Date()
          if code == 0
            @status = 'success'
          else
            @status = 'fail'
            @result = code.toString()
          GLOBAL.hook.emit 'job-status', runId: @_id, jobId: @jobId, name: @name, status: @status, completedAt: @completedAt
          @save()
          job.lastStatus = @status
          job.lastRanAt = @ranAt
          job.save (err) ->
            if err
              console.log("error saving job details: #{err}")

schema.methods.log = ->
  for arg in arguments
    if typeof arg in ['string', 'number']
      @output += new String(arg) + "\n"
    else
      @output += util.inspect(arg) + "\n"
  @save()

module.exports = mongoose.model 'Run', schema
