process.argv.push '--repl'

Hook = require('hook.io').Hook

opts = require('optimist')
       .usage("Start a repl process.\nUsage: $0")
       .describe('host', 'connect to host ip address')
       .demand('host')
       .alias('h', 'host')
       .describe('port', 'host port')
       .alias('p', 'port')
       .default('port', 5000)
argv = opts.argv

if argv.help
  console.log opts.help()
  process.exit()

hook = new Hook
  name: 'repl'
  "hook-host": argv.host
  "hook-port": argv.port

hook.connect()
