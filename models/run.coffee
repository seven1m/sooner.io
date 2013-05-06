util = require 'util'
_ = require 'underscore'
fs = require 'fs'

BASE_PATH = __dirname + '/..'

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
  workerName:
    type: String
  timeout:
    type: Number
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
  GLOBAL.hook.emit 'sync::trigger::run', _id: @_id

schema.methods.succeed = (callback) ->
  @status = 'success'
  @setProgress 'max'
  @refresh()
  @updateJob callback

schema.methods.fail = (message, callback) ->
  message += "\n"
  console.log 'job', @name, 'fail:', message
  @status = 'fail'
  @output += message
  @ranAt = @completedAt = new Date()
  @refresh message
  try
    @save (err) =>
      if err then throw err
      @updateJob =>
        if callback
          callback message
  catch err
    console.log 'could not save run'
    if callback
      callback message

schema.methods.failSilently = (message, callback) ->
  console.log 'job', @name, 'fail silently:', message
  @status = 'fail'
  @refresh message
  @save (err) =>
    @remove (err) =>
      if err then throw err
      if callback
        callback message

schema.methods.updateJob = (callback) ->
  models.job.findById @jobId, (err, job) =>
    if err then throw err
    job.lastStatus = @status
    job.lastRanAt = @ranAt
    job.save (err) =>
      if err then throw err
      GLOBAL.hook.emit 'sync::refresh::job', _id: job.id
      callback() if callback

schema.methods.refresh = (appendOutput) ->
  data = @toObject()
  delete data.output
  if appendOutput
    data.appendOutput = appendOutput
  GLOBAL.hook.emit 'sync::refresh::run', data

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
        @failSilently 'this job is already running', callback
      else
        @status = 'busy'
        @ranAt = new Date()
        @save()
        @updateJob()
        @refresh()
        timer = null

        script.on 'start', (pid) =>
          @pid = pid
          @refresh()
          @save()

        script.on 'data', (data) =>
          @output += data.toString()
          @refresh data.toString()
          @save()

        script.on 'end', (code) =>
          clearTimeout(timer) if timer
          @completedAt = new Date()
          @result = code
          if code == 0
            @succeed callback
          else
            @fail 'script exited with non-zero status code', callback

        script.on 'error', (err) =>
          @fail err, callback

        script.execute @data

        if job.timeout > 0
          console.log("Setting timeout for '#{@name}' of #{job.timeout} seconds")
          timer = setTimeout _.bind(@stop, @, "timeout (#{job.timeout})"), job.timeout * 1000

schema.methods.stoppable = ->
  @status in ['idle', 'busy']

schema.methods.stop = (reason) ->
  if @pid
    process.kill @pid, 'SIGINT'
    @fail "script killed by #{reason}"

schema.methods.setProgress = (current, max, callback) ->
  if current == 'max'
    @progress[0] = @progress[1]
  else
    @progress[0] = current
    @progress[1] = max unless typeof max == 'undefined' or max == null
  @markModified 'progress'
  @refresh()
  @save callback

module.exports = model = mongoose.model 'Run', schema

# attributes that should be synced via a list, i.e. not findOne
# (this excludes the 'output' attribute)
LISTABLE_ATTRS = ['jobId', 'name', 'hooks', 'data', 'progress', 'status', 'result',
                  'createdAt', 'path', 'pid', 'ranAt', 'completedAt']

model.sync = (socket) ->
  name = @modelName.toLowerCase()

  socket.on 'sync::read::run', (data, callback) =>
    if id = (data.id || data._id)
      @findById id, callback
    else
      attrs = {}; attrs[a] = true for a in LISTABLE_ATTRS
      data.sort ?= {createdAt: -1}
      q = @where('jobId', data.jobId).select(attrs).sort(data.sort)
      _.clone(q).count (err, count) ->
        if err
          console.log err
          callback(err.toString())
        else
          q.skip(data.skip).limit(Math.min(data.limit, 100)).exec (err, models) ->
            if err
              console.log err
              callback(err.toString())
            else
              callback null,
                count: count
                models: models

  socket.on 'sync::create::run', (data, callback) =>
    models.job.findById data.jobId, (err, job) =>
      if err
        console.log err
        callback err.toString()
      else
        run = job.newRun()
        run.data = data.data
        run.save (err, run) ->
          if err
            console.log err
            callback err.toString()
          else
            GLOBAL.hook.emit 'sync::refresh::job', _id: job.id
            callback null, run
