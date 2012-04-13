opts = require('optimist')
       .usage("Start a web process.\nUsage: $0")
       .describe('port', 'port to run the web server').default('port', 3000)
       .describe('config', 'path to config file').default('config', 'config.json').alias('c', 'config')
argv = opts.argv

if argv.help
  console.log opts.help()
  process.exit()

unless argv.config.match(/^\//)
  argv.config = "#{__dirname}/../#{argv.config}"

WebServer = require(__dirname + '/../lib/webserver')

new WebServer(argv)
