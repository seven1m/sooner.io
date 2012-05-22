fs = require 'fs'
mongoose = require 'mongoose'
Schema = mongoose.Schema
dbInfo = require __dirname + '/../lib/dbInfo'
_ = require 'underscore'

queues = {}

queue = (name) ->
  name = "queue_#{name}"
  model = queues[name]
  unless model
    schema = new Schema
      status: String
      data: {}
      createdAt: Date
      updatedAt: Date
    schema.pre 'save', (next) ->
      if !@createdAt
        @createdAt = @updatedAt = new Date()
      else
        @updatedAt = new Date()
      next()
    model = mongoose.model name, schema
    queues[name] = model
  model

module.exports = queue

queue.connect = ->
  if !mongoose.connection or mongoose.connection.readyState != 1
    # FIXME config path should be configurable
    @config = JSON.parse(fs.readFileSync(__dirname + '/../config.json'))
    mongoose.connect @config.db

queue.disconnect = ->
  mongoose.disconnect()

queue.sync = (socket) ->
  socket.on 'sync::read::queue', (data, callback) =>
    if id = data.id
      callback null, queue(id)
    else
      dbInfo.listCollections (collections) ->
        queues = ({name: q.replace(/^queue_/, '')} for q in collections when q.match(/^queue_/))
        callback null, queues

  socket.on 'sync::read::queue_entry', (data, callback) =>
    if id = (data.id || data._id)
      queue(data.queue).findById id, callback
    else
      q = queue(data.queue).find(data.query)
      q = q.sort.apply(q, data.sort || ['createdAt', -1])
      _.clone(q).count (err, count) ->
        if err
          console.log err
          callback(err.toString())
        else
          q.skip(data.skip).limit(Math.min(data.limit, 100)).run (err, models) ->
            if err
              console.log err
              callback(err.toString())
            else
              callback null,
                count: count
                models: models
