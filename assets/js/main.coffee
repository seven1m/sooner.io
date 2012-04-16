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

progressBar = (percent) ->
  "<div class='progress progress-striped'><div class='bar' style='width: #{percent}%;'></div></div>"

# FIXME Use Backbone.js to clean this up!
window.watchJobChanges = (jobId) ->
  socket.on 'log', (event, data) ->
    if !jobId || data.jobId == jobId
      if event.match(/running\-job/) and $("tr[data-run-meta=#{data.runId}]").length == 0
        table = $("#job-history-table tbody")
        table.prepend "<tr class='output' data-run-id='#{data.runId}' style='display:none;'><td class='formatted' colspan='5' data-run-output='#{data.runId}'></td></tr>"
        row = $("<tr data-run-meta='#{data.runId}'/>")
        row.append "<td><a class='show-output' href='#' data-run-id='#{data.runId}'><i class='icon-plus'/></a> <a href='/runs/#{data.runId}'>#{data.runId}</a></td>"
        row.append "<td class='ran-at'>#{new Date(data.ranAt).toString('M/dd/yyyy h:mm:ss tt')}</td>"
        row.append "<td class='completed-at'></td>"
        row.append "<td class='progress-cell'>#{progressBar 0}</td>"
        row.append "<td class='status'><i class='icon-cog'></i> busy</td>"
        table.prepend row
      else if event.match(/job\-output/)
        $("[data-run-output=#{data.runId}]").append formatLinks(data.output)
      else if event.match(/job\-status/)
        $("[data-run-meta=#{data.runId}] td.status").html("<i class='icon-#{statusIcons[data.status]}'></i> #{data.status}")
        if data.ranAt
          $("[data-run-meta=#{data.runId}] td.ran-at").html(new Date(data.ranAt).toString('M/dd/yyyy h:mm:ss tt'))
        if data.completedAt
          $("[data-run-meta=#{data.runId}] td.completed-at").html(new Date(data.completedAt).toString('M/dd/yyyy h:mm:ss tt'))
        if data.result
          $("[data-run-meta=#{data.runId}] td.result").html(data.result)
        progress = $("[data-run-meta=#{data.runId}] td.progress-cell .progress")
        if data.status == 'busy'
          progress.addClass('active')
        else
          progress.removeClass('active')
          if data.status == 'fail'
            progress.addClass('progress-danger')
      else if event.match(/job\-progress/)
        $("[data-run-meta=#{data.runId}] td.progress-cell .progress .bar").css('width', data.progressPercent + '%')

window.formatLinks = (text) ->
  $('<div/>').text(text).html().replace(/https?:\/\/\S+/g, "<a href='$&'>$&</a>")

$ ->
  $('#show-queue-query').click ->
    $('#queue-query').toggle()
  $(document).on 'click', 'a.show-output', (e) ->
    e.preventDefault()
    elm = $(this)
    id = elm.data('run-id')
    $(".output[data-run-id=#{id}]").toggle()
    elm.find('i').toggleClass('icon-plus').toggleClass('icon-minus')
