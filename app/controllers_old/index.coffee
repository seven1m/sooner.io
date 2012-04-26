fs = require 'fs'

for file in fs.readdirSync(__dirname)
  if file.match(/\.coffee$/) && !file.match(/index\.coffee/)
    name = file.substr 0, file.indexOf('.')
    exports[name] = require('./' + name)
