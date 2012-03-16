fs = require 'fs'
mongoose = require 'mongoose'
Schema = mongoose.Schema

exports.init = (context, options) ->

  queues = {}

  context.queue = (name) ->
    name = "queue_#{name}"
    model = queues[name]
    unless model
      schema = new Schema()
      model = mongoose.model name, schema
      queues[name] = model
    model
