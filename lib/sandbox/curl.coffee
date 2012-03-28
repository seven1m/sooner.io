curl = require 'node-curl'
fs = require 'fs'
childProcess = require 'child_process'

basePath = fs.realpathSync(__dirname + '/../../output/')

exports.init = (context, options) ->
  servers = options.curlServers || {}

  safePath = (path, inBase) ->
    if path.indexOf('..') > -1
      return false
    if inBase and path.indexOf(basePath) == -1
      return false
    return true

  context.curl =

    upload: (path, conn, subDir, callback) ->
      path = fs.realpathSync("#{basePath}/#{path}")
      if safePath(path, 'inBase')
        destination = servers[conn]
        if destination
          preArgs = []
          if subDir
            if safePath(subDir)
              destination += '/' unless destination.match(/\/$/)
              rootPath = destination.replace(/^[a-z]+:\/\//i, '').replace(/^[^\/]+/, '')
              destination += subDir
              destination += '/' unless destination.match(/\/$/)
              parts = subDir.split('/')
              for sub, i in parts
                preArgs.push '-Q'
                preArgs.push "*MKD #{rootPath}#{parts[0..i].join('/')}"
            else
              throw "Invalid path."
          args = preArgs.concat(['-T', path, destination])
          proc = childProcess.spawn "curl", args
          out = ''
          proc.stdout.on 'data', (data) -> out += data.toString()
          proc.stderr.on 'data', (data) -> out += data.toString()
          proc.on 'exit', (code) -> callback code, out
        else
          throw "connection '#{conn}' not configured in config.json"
      else
        throw "Invalid path."
