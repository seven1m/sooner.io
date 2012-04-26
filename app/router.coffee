class app.router extends Backbone.Router

  routes:
    '': 'default'
    'jobs': 'jobsIndex'

  default: ->
    @navigate 'jobs'

  jobsIndex: ->
    jobIndexView = new app.views.jobIndex().render()
    $('#main .root').html jobIndexView.$el
