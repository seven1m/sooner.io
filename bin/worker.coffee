opts = require('optimist').usage("Start a worker process.\nUsage: $0")
       .describe('name', 'name this worker').default('name', 'worker').alias('n', 'name')
       .describe('config', 'path to config file').default('config', 'config.json').alias('c', 'config')
argv = opts.argv

if argv.help
  console.log opts.help()
  process.exit()

unless argv.config.match(/^\//)
  argv.config = "#{__dirname}/../#{argv.config}"

Worker = require(__dirname + '/../lib/worker')

new Worker(argv)
