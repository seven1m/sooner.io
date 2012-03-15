pg = require 'pg'
fs = require 'fs'

exports.init = (context, options) ->
  connections = options.connections

  context.connection = class
    constructor: (conn) ->
      @conn = conn
    query: (sql, cb) ->
      @conn.query sql, (err, result) =>
        cb err, result && result.rows

  context.db =
    connect: (conn, callback) ->
      connStr = connections[conn]
      if connStr
        if connStr.match /^postgres:/
          pg.connect connStr.replace(/^postgres:/, 'tcp:'), (err, client) ->
            if err
              throw err
            callback(err, new context.connection(client))
        else
          throw 'unsupported database type'
      else
        throw 'database not configured (add it to config.json)'
