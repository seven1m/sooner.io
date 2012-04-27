class app.router extends Backbone.Router

  routes:
    '':         'default'
    'jobs':     'jobsIndex'
    'jobs/:id': 'jobsShow'

  default: ->
    @navigate 'jobs', trigger: yes

  jobsIndex: ->
    app.view.remove() if app.view
    v = app.view = new app.views.jobs.index(collection: app.data.jobs).render()
    $('#main .root').html v.$el

  jobsShow: (id) ->
    app.view.remove() if app.view
    m = app.data.jobs.get(id)
    unless m
      m = new app.models.job(id: id)
      m.fetch
        error: -> $('#main .root').html 'Job not found.'
    v = app.view = new app.views.jobs.show(model: m).render()
    $('#main .root').html v.$el
