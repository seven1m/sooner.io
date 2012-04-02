fs = require 'fs'
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
      path = fs.realpathSync("#{basePath}/#{path}")
      if path.indexOf(basePath) == 0 and path.indexOf('..') == -1
        fs.createWriteStream path
      else
        throw "Invalid path."
