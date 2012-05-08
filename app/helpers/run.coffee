app.helpers ?= {}

app.helpers.progressClass = (status) ->
  classes = ['progress', 'progress-striped']
  classes.push 'active' if status == 'busy'
  if status == 'fail'
    classes.push 'progress-danger'
  else if status == 'success'
    classes.push 'progress-info'
  else
    classes.push 'progress-success'
  classes.join ' '
