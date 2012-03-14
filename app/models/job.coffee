Sandbox = require(__dirname + '/../../lib/sandbox')

util = require 'util'
_ = require 'underscore'

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
    enum: ['busy', 'idle']
    default: 'idle'
  output:
    type: String
  createdAt:
    type: Date
    default: -> new Date()
  ranAt:
    type: Date

schema.methods.run = (callback) ->
  console.log "running #{@name}..."
  GLOBAL.hook.emit 'run-job', jobId: @_id, workflowId: @workflowId, name: @name
  @status = 'busy'
  @ranAt = new Date()
  sandbox = new Sandbox(_.bind(@log, @))
  sandbox.run(new String(@definition))
  @save(callback)

schema.methods.log = ->
  for arg in arguments
    @output += util.inspect(arg)
  @save()

module.exports = mongoose.model 'Job', schema
