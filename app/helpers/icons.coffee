exports.statusIcon = (status) ->
  if status == 'success'
    "<i class='icon-ok'></i>"
  else if status == 'fail'
    "<i class='icon-exclamation-sign'></i>"
  else if status == 'busy'
    "<i class='icon-cog'></i>"
  else if status == 'idle'
    "<i class='icon-time'></i>"

