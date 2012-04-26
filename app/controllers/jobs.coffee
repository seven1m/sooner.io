app.controllers.jobs =

  index: ->
    jobIndexView = new app.views.jobIndex().render()
    $('#main .root').html jobIndexView.$el

  show: (id) ->
    console.log 'show job', id
