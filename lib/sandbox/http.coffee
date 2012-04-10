http = require 'http'
url = require 'url'

exports.init = (context, options) ->

  context.http = http
  context.url = url
