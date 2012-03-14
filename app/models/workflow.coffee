mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  name:
    type: String
    required: true
  schedule:
    type: String
    match: /^((\*|[\d\-,]+)(\/\d+)?\s+){4}(\*|[\d\-,]+)(\/\d+)?$/ # very loose
  createdAt:
    type: Date
    default: -> new Date()

module.exports = mongoose.model 'Workflow', schema
