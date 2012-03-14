process.argv.push '--repl'

Hook = require('hook.io').Hook

argv = require('optimist')
       .usage("Start a repl process.\nUsage: $0")
       .demand('h')
       .alias('h', 'host')
       .describe('h', 'connect to host ip address')
       .alias('p', 'port')
       .describe('p', 'host port')
       .default('port', 5000)
       .argv

hook = new Hook
  name: 'repl'
  "hook-host": argv.host
  "hook-port": argv.port

hook.connect()
