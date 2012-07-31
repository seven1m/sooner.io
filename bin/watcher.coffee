opts = require('optimist').usage("Start a watcher process.\nUsage: $0")
       .describe('name', 'name this watcher').default('name', 'watcher').alias('n', 'name')
       .describe('config', 'path to config file').default('config', 'config.json').alias('c', 'config')
       .describe('debug', 'enable additional debugging messages').default('debug', false)
argv = opts.argv

if argv.help
  console.log opts.help()
  process.exit()

unless argv.config.match(/^\//)
  argv.config = "#{__dirname}/../#{argv.config}"

Watcher = require(__dirname + '/../lib/watcher')

new Watcher(argv)
