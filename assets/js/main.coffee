window.socket = io.connect()

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
  else if prop == 'jobId'
    val = "<a href='/jobs/#{val}'>#{val}</a>"
  else
    val = $('<div/>').text(JSON.stringify(val)).html()
  "<tr><td>#{prop}:</td><td>#{val}</td></tr>"

statusIcons =
  success: 'ok'
  fail:    'exclamation-sign'
  busy:    'cog'
  idle:    'time'

window.watchJobChanges = (jobId) ->
  socket.on 'log', (event, data) ->
    if !jobId || data.jobId == jobId
      if event.match(/running\-job/) and $("tr[data-run-meta=#{data.runId}]").length == 0
        table = $("#job-history-table tbody")
        table.prepend "<tr><td class='formatted' colspan='4' data-run-output='#{data.runId}'></td></tr>"
        row = $("<tr data-run-meta='#{data.runId}'/>")
        row.append "<td><a href='/runs/#{data.runId}'>#{data.runId}</a></td>"
        row.append "<td class='ran-at'>#{new Date(data.ranAt).toString('M/dd/yyyy h:mm:ss tt')}</td>"
        row.append "<td class='completed-at'></td>"
        row.append "<td class='status'><i class='icon-cog'></i> busy</td>"
        table.prepend row
      else if event.match(/job\-output/)
        html = $('<div/>').text(data.output).html().replace(/https?:\/\/\S+/g, "<a href='$&'>$&</a>")
        $("[data-run-output=#{data.runId}]").append(html)
      else if event.match(/job\-complete/)
        $("[data-run-meta=#{data.runId}] td.status").html("<i class='icon-#{statusIcons[data.status]}'></i> #{data.status}")
        $("[data-run-meta=#{data.runId}] td.completed-at").html(new Date(data.completedAt).toString('M/dd/yyyy h:mm:ss tt'))

