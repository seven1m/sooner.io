os = require 'os'

exports.ifaces = ->
  ifs = os.networkInterfaces()
  ips = []
  for d of ifs
    for ip in ifs[d] when ip.family == 'IPv4' and ip.address != '127.0.0.1'
      ips.push ip.address
  ips
