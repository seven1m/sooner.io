fs = require 'fs'
basePath = fs.realpathSync(__dirname + '/../../output/')

exports.init = (context, options) ->

  context.fs =

    readStream: (path) ->
      path = fs.realpathSync(path)
      if path.indexOf(basePath) == 0
        fs.createReadStream path
      else
        throw "Invalid path."
