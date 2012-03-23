window.socket = io.connect()

updateDelay = 30000

socket.on 'i-am', (node) ->
  html = "<tr><td>#{node.name}</td><td>#{node.host}</td><td>#{node.port || ''}</td></tr>"
  $('#nodes tbody').append html

window.showNodes = ->
  $('#nodes tbody').html('')
  socket.emit 'list-nodes'

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
      else if event.match(/job\-status/)
        $("[data-run-meta=#{data.runId}] td.status").html("<i class='icon-#{statusIcons[data.status]}'></i> #{data.status}")
        if data.ranAt
          $("[data-run-meta=#{data.runId}] td.ran-at").html(new Date(data.ranAt).toString('M/dd/yyyy h:mm:ss tt'))
        if data.completedAt
          $("[data-run-meta=#{data.runId}] td.completed-at").html(new Date(data.completedAt).toString('M/dd/yyyy h:mm:ss tt'))

