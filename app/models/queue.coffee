mongoose = require 'mongoose'
Schema = mongoose.Schema

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
