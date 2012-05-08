mongoose = require 'mongoose'
Schema = mongoose.Schema
dbInfo = require __dirname + '/../lib/dbInfo'

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

queue.sync = (socket) ->
  socket.on 'sync::read::queue', (data, callback) =>
    if id = data.id
      callback null, queue(id)
    else
      dbInfo.listCollections (collections) ->
        queues = ({name: q.replace(/^queue_/, '')} for q in collections when q.match(/queue_/))
        console.log queues
        callback null, queues
