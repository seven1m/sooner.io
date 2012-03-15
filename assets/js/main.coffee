window.socket = io.connect()

socket.bridge = (event, callback) ->
  socket.on event, callback
  socket.emit 'bridge', event

updateDelay = 30000

socket.on 'i-am', (node) ->
  html = "<tr><td>#{node.name}</td><td>#{node.host}</td><td>#{node.port}</td></tr>"
  $('#nodes tbody').append html

window.showNodes = ->
  $('#nodes tbody').html('')
  socket.emit 'list-nodes'
  setTimeout showNodes, updateDelay

maxLogLines = 1000
window.showLog = ->
  socket.on 'log', (event, data) ->
    props = (propRow(prop, val) for prop, val of data)
    data = "<table>#{props.join('')}</table>"
    console.log data
    row = "<tr><td>#{event}</td><td>#{data}</td><td>#{new Date().toString 'h:mm:ss tt'}</td></tr>"
    e = $('#log tbody').eq(0)
    e.prepend row

propRow = (prop, val) ->
  if prop == 'runId'
    val = "<a href='/runs/#{val}'>#{val}</a>"
  else if prop == 'workflowId'
    val = "<a href='/workflows/#{val}'>#{val}</a>"
  else
    val = $('<div/>').text(JSON.stringify(val)).html()
  "<tr><td>#{prop}:</td><td>#{val}</td></tr>"
