childProcess = require 'child_process'
fs = require 'fs'
temp = require 'temp'
dnode = require 'dnode'
EventEmitter2 = require('eventemitter2').EventEmitter2

class Script extends EventEmitter2

  constructor: (@path, @funcs) ->
    if @path.trim() != ''
      try
        @realPath = fs.realpathSync(@path)
      catch e
        @realPath = null

  openSocket: =>
    @sockPath = temp.path suffix: '.sock'
    @socket = dnode @funcs
    @socket.listen @sockPath

  closeSocket: =>
    @socket.end()
    fs.unlink @sockPath, (err) =>
      console.log(err) if err

  execute: (data) =>
    @openSocket()
    if @realPath
      input = JSON.stringify(data || {})
      child = childProcess.spawn @realPath, [@sockPath, input], {}
      @emit 'start', child.pid.toString()
      child.stdout.on 'data', (data) =>
        @emit 'data', data.toString()
      child.stderr.on 'data', (data) =>
        @emit 'data', data.toString()
      child.on 'exit', (code) =>
        @closeSocket()
        @emit 'end', code
    else
      @emit 'error', 'could not find path'

module.exports = Script
