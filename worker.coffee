Hook = require('hook.io').Hook
vm = require('vm')

argv = require('optimist')
       .usage("Start a worker process.\nUsage: $0")
       .demand('h')
       .alias('h', 'host')
       .describe('h', 'host ip address; use own ip if this is to be the main worker process.')
       .alias('p', 'port')
       .describe('p', 'host port, defaults to 5000')
       .default('p', 5000)
       .alias('c', 'connect')
       .describe('c', 'connect to a remote host (use this option if not the server)')
       .argv

hook = new Hook
  name: 'worker'
  "hook-host": argv.host
  "hook-port": argv.port

if argv.connect
  hook.connect()
else
  hook.listen()

# start of basic sandboxing
try
  context =
    console: console
  vm.runInNewContext('console.log(13)', context, 'sandbox.vm')
catch err
  console.log(err)
