util = require 'util'
_ = require 'underscore'
fs = require 'fs'

BASE_PATH = __dirname + '/../../..'

Script = require "#{BASE_PATH}/lib/script"

models = require __dirname
mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

scriptsDir = "#{BASE_PATH}/scripts-working-copy"

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
  pid:
    type: String
  ranAt:
    type: Date
  completedAt:
    type: Date

schema.methods.fullPath = ->
  scriptsDir + '/' + @path

schema.methods.trigger = ->
  @hookEmit 'trigger-job'

schema.methods.hookEmit = (event, data) ->
  defData =
    runId: @_id
    jobId: @jobId
    name: @name
    status: @status
    result: if @result then @result.toString()
    ranAt: @ranAt
    completedAt: @completedAt
  GLOBAL.hook.emit event, _.extend(defData, data)

schema.methods.succeed = (callback) ->
  @status = 'success'
  @setProgress 'max'
  @hookEmit 'job-status'
  @updateJob callback

schema.methods.fail = (message, callback) ->
  console.log 'job', @name, 'fail:', message
  @status = 'fail'
  @output += message
  @ranAt = @completedAt = new Date()
  @hookEmit 'job-output', output: message
  @hookEmit 'job-status'
  @save (err) =>
    if err then throw err
    @updateJob =>
      if callback
        callback message

schema.methods.updateJob = (callback) ->
  models.job.findById @jobId, (err, job) =>
    if err then throw err
    job.lastStatus = @status
    job.lastRanAt = @ranAt
    job.save (err) =>
      if err then throw err
      callback()

schema.methods.run = (callback) ->
  models.job.findById @jobId, (err, job) =>
    if err or !job then throw ['error getting job:', err]

    script = new Script @fullPath(),
      emit: (event, data) =>
        console.log "job #{@name} emitted '#{event}' with data", data
        _.debounce(GLOBAL.hook.emit, 50, true)(event, data)
      progress: _.debounce(_.bind(@setProgress, @), 50, true)

    # FIXME: race condition
    models.run.where('status', 'busy').where('jobId', @jobId).count (err, runningCount) =>
      if err then throw err

      if runningCount > 0 and job.mutex
        @fail 'this job is already running', callback
      else
        @status = 'busy'
        @ranAt = new Date()
        @save()
        @hookEmit 'job-status'

        script.on 'start', (pid) =>
          @pid = pid
          @hookEmit 'running-job', pid: @pid
          @save()

        script.on 'data', (data) =>
          @output += data.toString()
          @hookEmit 'job-output', pid: @pid, output: data.toString()
          @save()

        script.on 'end', (code) =>
          @completedAt = new Date()
          @result = code
          if code == 0
            @succeed callback
          else
            @fail 'script exited with non-zero status code', callback

        script.on 'error', (err) =>
          @fail err, callback

        script.execute @data

schema.methods.stoppable = ->
  @status in ['idle', 'busy']

schema.methods.stop = ->
  if @pid
    process.kill @pid, 'SIGINT'

schema.methods.setProgress = (current, max, callback) ->
  if current == 'max'
    @progress[0] = @progress[1]
  else
    @progress[0] = current
    @progress[1] = max unless typeof max == 'undefined'
  @markModified 'progress'
  @hookEmit 'job-progress', progress: @progress, progressPercent: @progressPercent()
  @save callback

schema.methods.progressPercent = ->
  try
    Math.min(100, @progress[0] / @progress[1] * 100)
  catch e
    0

module.exports = model = mongoose.model 'Run', schema

model.sync = (socket) ->
  name = @modelName.toLowerCase()
  socket.on "#{name}:read", (data, callback) =>
    if data.id || data._id
      @findOne _id: data.id || data._id, callback
    else
      q = @where('jobId', data.jobId)
      q = q.sort.apply(q, data.sort || ['ranAt', -1])
      _.clone(q).count (err, count) ->
        if err
          console.log err
          callback(err)
        else
          q.skip(data.skip).limit(Math.min(data.limit, 100)).run (err, runs) ->
            if err
              console.log err
              callback(err.toString())
            else
              callback null,
                count: count
                models: runs
