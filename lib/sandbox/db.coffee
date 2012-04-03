pg = require 'pg'
fs = require 'fs'

exports.init = (context, options) ->
  connections = options.dbConnections || {}

  context.connection = class
    constructor: (conn) ->
      @conn = conn
    query: (sql, params, cb) ->
      if typeof params == 'function'
        cb = params
        params = []
      @conn.query sql, params, (err, result) =>
        if err then throw err
        cb(result && result.rows)
    end: ->
      @conn.end()

  context.db =
    connect: (conn, callback) ->
      connStr = connections[conn]
      if connStr
        if connStr.match /^postgres:/
          client = new pg.Client connStr.replace(/^postgres:/, 'tcp:')
          client.connect();
          callback(new context.connection(client))
        else
          throw 'unsupported database type'
      else
        throw 'database not configured (add it to config.json)'
