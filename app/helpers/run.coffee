app.helpers ?= {}

app.helpers.runStatusClass = (run) ->
  if run.status == 'busy'
    'active'
  else if run.status == 'fail'
    'progress-danger'
