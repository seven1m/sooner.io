opts = require('optimist')
       .usage("Run the deployer.\nUsage: $0 update")
       .describe('config', 'path to config file').default('config', 'config.json').alias('c', 'config')
argv = opts.argv

if argv.help
  console.log opts.help()
  process.exit()

unless argv.config.match(/^\//)
  argv.config = "#{__dirname}/../#{argv.config}"

Deployer = require(__dirname + '/../lib/deployer')
deployer = new Deployer(argv)

if argv._[0] == 'update'
  deployer.update ->
    deployer.end()
    process.exit()
else
  console.log 'must specify a command, such as "update"'
  process.exit(1)
