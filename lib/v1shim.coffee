fs = require 'fs'
config = JSON.parse(fs.readFileSync(__dirname + '/../config.json'))

_ = require 'underscore'

if data = process.argv[3]
  try
    exports.data = JSON.parse(data)
  catch e
    console.warn "Warning: could not parse incoming data", data
    exports.data = {}
else
  exports.data = null

exports.bind = _.bind

exports.emit = (hook) ->
  console.error ">>> sooner.emit('#{hook}')"

exports.progress = (current, max) ->
  console.error ">>> sooner.progress(#{current}, #{max || 'null'})"


# PostgreSQL Database
# # # # # # # # # # #

pg = require 'pg'

class DbConnection
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

exports.db =
  connect: (conn, callback) ->
    connStr = config.dbConnections[conn]
    if connStr
      if connStr.match /^postgres:/
        client = new pg.Client connStr.replace(/^postgres:/, 'tcp:')
        client.connect();
        callback(new DbConnection(client))
      else
        throw 'unsupported database type'
    else
      throw 'database not configured (add it to config.json)'


# Filesystem Access
# # # # # # # # # #

carrier = require 'carrier'
basePath = fs.realpathSync(__dirname + '/../output/')

exports.fs =
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


# FTP Connectivity
# # # # # # # # # #

FTPClient = require 'ftp'

class FTPConnection
  constructor: (connDetails, callback) ->
    client = new FTPClient(host: connDetails.host)
    @list = (path, cb) ->
      listing = []
      client.list path, (err, iter) ->
        if err
          cb(err)
        else
          iter.on 'entry', (entry) ->
            listing.push(entry)
          iter.on 'end', ->
            cb(null, listing)

    @mkdir = (name, cb) ->
      client.mkdir(name, cb)
    @put = (inStream, filename, cb) ->
      client.put(inStream, filename, cb)
    @get = (filename, cb) ->
      client.get(filename, cb)
    @rename = (oldFilename, newFilename, cb) ->
      client.rename(oldFilename, newFilename, cb)
    @end = ->
      client.end()
    client.on 'connect', =>
      client.auth connDetails.username, connDetails.password, (err) =>
        callback(err, @)
    client.connect()

exports.ftp =

  connect: (conn, callback) ->
    connDetails = config.ftpServers[conn]
    if connDetails
      new FTPConnection connDetails, callback
    else
      throw "connection '#{conn}' not configured in config.json"


# HTTP
# # # #

exports.http = require 'http'
exports.url = require 'url'


# Queue
# # # #

exports.queue = require __dirname + '/../models/queue'
exports.queue.connect()


# Shell
# # # #

childProcess = require 'child_process'

# low-level, creates a ChildProcess
exports.shell = {}
exports.shell.spawn = (cmd, args) ->
  cmdStr = config.shellCommands[cmd]
  if cmdStr
    childProcess.spawn cmdStr, args
  else
    throw "command '#{cmd}' not configured in config.json"
  
# high-level, runs command and executes callback with
# return code and captured stdout+stderr
exports.shell.run = (cmd, args, callback) ->
  proc = exports.shell.spawn cmd, args
  out = ''
  proc.stdout.on 'data', (data) -> out += data.toString()
  proc.stderr.on 'data', (data) -> out += data.toString()
  proc.on 'exit', (code) -> callback code, out


# XML
# # #

xml2js = require 'xml2js'

exports.stringToJSON = (string, callback) ->
  parser = new xml2js.Parser()
  parser.parseString string, (err, result) ->
    callback(err, result)

exports.fileToJSON = (path, callback) ->
  path = fs.realpathSync("#{basePath}/#{path}")
  if path.indexOf(basePath) == 0 and path.indexOf('..') == -1
    fs.readFile path, (err, data) ->
      if err then throw err
      exports.stringToJSON data, callback
  else
    throw "Invalid path."


# Miscellaneous
# # # # # # # #

exports.done = ->
  exports.queue.disconnect()
  process.exit()


# Global Namespace Pollution
# # # # # # # # # # # # # # #

exports.pollute = ->
  for name, obj of exports when name != 'pollute'
    GLOBAL[name] = obj

