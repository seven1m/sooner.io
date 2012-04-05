module.exports =

  runStatusClass: (run) ->
    if run.status == 'busy'
      'active'
    else if run.status == 'fail'
      'progress-danger'
