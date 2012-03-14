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

schema.methods.run = (callback) ->
  console.log "running #{@name}..."
  GLOBAL.hook.emit 'running-job', jobId: @_id, workflowId: @workflowId, name: @name
  @status = 'busy'
  @ranAt = new Date()
  sandbox = new Sandbox(_.bind(@log, @))
  sandbox.run new String(@definition), (err, result) =>
    if err
      @result = util.inspect(err)
      @status = 'fail'
    else
      @result = util.inspect(result)
      # TODO if no running hooks
      @status = 'success'
    @save
  @save(callback)

schema.methods.log = ->
  for arg in arguments
    if typeof arg in ['string', 'number']
      @output += new String(arg) + "\n"
    else
      @output += util.inspect(arg) + "\n"
  @save()

module.exports = mongoose.model 'Job', schema
