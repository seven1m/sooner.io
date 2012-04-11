fs = require 'fs'
carrier = require 'carrier'
basePath = fs.realpathSync(__dirname + '/../../output/')

exports.init = (context, options) ->

  context.fs =

    readStream: (path) ->
      path = fs.realpathSync("#{basePath}/#{path}")
      if path.indexOf(basePath) == 0 and path.indexOf('..') == -1
        fs.createReadStream path
      else
        throw "Invalid path."

    writeStream: (path) ->
      path = "#{basePath}/#{path}"
      if path.indexOf(basePath) == 0 and path.indexOf('..') == -1
        fs.createWriteStream path
      else
        throw "Invalid path."
        
    readStreamByLine: (path, callback) ->
      stream = fs.createReadStream("#{basePath}/#{path}")
      stream.on 'open', ->
        line_reader = carrier.carry(stream)
        line_reader.on 'line', (line) ->
          callback(null, 'line', line)
      stream.on 'end', ->
        callback(null, 'end', null)
      stream.on 'error', (err) ->
        callback(err, 'error')