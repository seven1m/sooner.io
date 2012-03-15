Sandbox = require(__dirname + '/../../lib/sandbox')

util = require 'util'
_ = require 'underscore'

models = require __dirname
mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

schema = new Schema
  workflowId:
    type: ObjectId
    required: true
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
  GLOBAL.hook.emit 'trigger-job', jobId: @_id, workflowId: @workflowId, name: @name

schema.methods.run = (callback) ->
  console.log "running #{@name}..."
  GLOBAL.hook.emit 'running-job', jobId: @_id, workflowId: @workflowId, name: @name
  @status = 'busy'
  @ranAt = new Date()
  sandbox = new Sandbox(_.bind(@log, @))
  sandbox.run new String(@definition), (err, result) =>
    if err
      @result = "#{err}\n#{err.stack || '(no stack trace)'}"
      @status = 'fail'
    else
      @result = util.inspect(result)
      if result == true
        # TODO if no running hooks
        @status = 'success'
      else
        @status = 'fail'
    GLOBAL.hook.emit 'job-complete', jobId: @_id, workflowId: @workflowId, name: @name, status: @status
    @save
    models.workflow.update {_id: @workflowId}, {lastStatus: @status, lastRanAt: @ranAt}, (err, _) ->
      if err
        console.log("error saving workflow details: #{err}")
  @save(callback)

schema.methods.log = ->
  for arg in arguments
    if typeof arg in ['string', 'number']
      @output += new String(arg) + "\n"
    else
      @output += util.inspect(arg) + "\n"
  @save()

module.exports = mongoose.model 'Job', schema
