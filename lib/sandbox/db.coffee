pg = require 'pg'
fs = require 'fs'

exports.init = (context, options) ->
  options ||= {}
  connections = options.connections || JSON.parse(fs.readFileSync(__dirname + '/../../config.json')).connections

  context.db =
    connect: (conn, callback) ->
      connStr = connections[conn]
      if connStr
        if connStr.match /^postgres:/
          pg.connect connStr.replace(/^postgres:/, 'tcp:'), (err, client) ->
            if err
              throw err
            callback(err, client)
        else
          throw 'unsupported database type'
      else
        throw 'database not configured (add it to config.json)'
