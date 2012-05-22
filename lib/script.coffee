childProcess = require 'child_process'
fs = require 'fs'
temp = require 'temp'
dnode = require 'dnode'
carrier = require 'carrier'
EventEmitter2 = require('eventemitter2').EventEmitter2

class Script extends EventEmitter2

  RPCRE: /(^|\n)\s*>>>\s*(sooner\.[a-zA-Z0-9_]+\(.*\))/

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
      child = childProcess.spawn @realPath, [data, @sockPath], {}

      @emit 'start', child.pid.toString()

      child.stdout.on 'data', (data) =>
        @emit 'data', data.toString()

      # intercept side channel rpc
      carrier.carry child.stderr, (line) =>
        line = line.toString()
        if m = line.match(@RPCRE)
          sooner = @funcs
          eval m[2]
        else
          @emit 'data', line

      child.on 'exit', (code) =>
        @closeSocket()
        @emit 'end', code

    else
      @emit 'error', 'could not find path'

module.exports = Script
