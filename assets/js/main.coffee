window.socket = io.connect()

socket.bridge = (event, callback) ->
  socket.on event, callback
  socket.emit 'bridge', event

updateDelay = 30000
window.showNodes = ->
  socket.on 'info', (nodes) ->
    html = ("<tr><td>#{node.name}</td><td>#{node.remote.host}:#{node.remote.port}</td></tr>" for node in nodes).join('')
    $('#nodes tbody').html(html)
  socket.emit 'info'
  setInterval (-> socket.emit 'info'), updateDelay

maxLogLines = 1000
window.showLog = ->
  socket.bridge '**::worker::**', (event, data) ->
    row = "<tr><td>#{event.split('::')[0]}</td><td>#{event}</td><td>#{JSON.stringify data}</td><td>#{new Date().toString 'h:mm:ss tt'}</td></tr>"
    e = $('#log tbody')
    e.prepend row
