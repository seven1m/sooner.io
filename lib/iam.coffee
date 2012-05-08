os = require 'os'

ifaces = exports.ifaces = ->
  ifs = os.networkInterfaces()
  ips = []
  for d of ifs
    for ip in ifs[d] when ip.family == 'IPv4' and ip.address != '127.0.0.1'
      ips.push ip.address
  ips

exports.setup = (hook, base) ->
  info = base || {}
  info.name = hook.name
  info.host = ifaces().join(', ')
  hook.on 'cxn::list-nodes', ->
    hook.emit 'cxn::i-am', info
