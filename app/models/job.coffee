mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  workflow_id:
    type: Number
    required: true
  definition:
    type: String
  hooks:
    type: Array
  data:
    type: Array
  status:
    type: String
    enum: ['busy', 'idle']
  createdAt:
    type: Date
    default: -> new Date()

module.exports = mongoose.model 'Job', schema
