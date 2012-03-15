childProcess = require 'child_process'

exports.init = (context, options) ->
  commands = options.shellCommands

  # low-level, creates a ChildProcess
  context.spawn = (cmd, args) ->
    cmdStr = commands[cmd]
    if cmdStr
      childProcess.spawn cmdStr, args
    else
      throw "command '#{cmd}' not configured in config.json"

  # high-level, runs command and executes callback with
  # return code and captured stdout+stderr
  context.run = (cmd, args, callback) ->
    proc = context.spawn cmd, args
    out = ''
    proc.stdout.on 'data', (data) -> out += data.toString()
    proc.stderr.on 'data', (data) -> out += data.toString()
    proc.on 'exit', (code) -> callback code, out
