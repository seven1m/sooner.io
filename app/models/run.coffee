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
    type: Array
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

schema.methods.trigger = ->
  GLOBAL.hook.emit 'trigger-job', runId: @_id, jobId: @jobId, name: @name

schema.methods.run = (callback) ->
  console.log "running #{@name}..."
  @status = 'busy'
  @ranAt = new Date()
  @save(callback)

  sandbox = childProcess.spawn "coffee", ["#{__dirname}/../../lib/sandbox.coffee"], {}
  sandbox.stdin.end @definition
  GLOBAL.hook.emit 'running-job', pid: sandbox.pid, runId: @_id, jobId: @jobId, name: @name
  sandbox.stdout.on 'data', (data) =>
    @output += data.toString()
    @save()
  sandbox.stderr.on 'data', (data) =>
    @output += data.toString()
    @save()
  sandbox.on 'exit', (code) =>
    if code == 0
      @status = 'success'
    else
      @status = 'fail'
      @result = code.toString()
    GLOBAL.hook.emit 'job-complete', runId: @_id, jobId: @jobId, name: @name, status: @status
    @save()
    models.job.update {_id: @jobId}, {lastStatus: @status, lastRanAt: @ranAt}, (err, _) ->
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
