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

  jobsShow: (id, params) ->
    app.data.jobs.getOrFetch id, (err, job) ->
      if err
        $('#main .root').html 'error'
      else
        if (v = app.view) and (v instanceof app.views.jobs.show) and (v.model.id == job.id)
          v.setHistoryPage(params.page) if params
        else
          app.view.remove() if app.view
          historyPage = (params && params.page) || 1
          v = app.view = new app.views.jobs.show(model: job, historyPage: historyPage).render()
          $('#main .root').html v.$el
