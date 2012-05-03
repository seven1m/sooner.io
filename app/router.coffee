class app.router extends Backbone.Router

  routes:
    '':              'default'
    'jobs':          'jobsIndex'
    'jobs/:id':      'jobsShow'
    'jobs/:id/edit': 'jobsEdit'
    'runs/:id':      'runsShow'

  default: ->
    @navigate 'jobs', trigger: yes

  jobsIndex: ->
    app.view.remove() if app.view
    v = app.view = new app.views.jobs.index(collection: app.data.jobs).render()
    $('#main .root').html v.$el

  jobsShow: (id, params) ->
    app.data.jobs.getOrFetch id, (err, job) ->
      if err
        $('#main .root').html err
      else
        if (v = app.view) and (v instanceof app.views.jobs.show) and (v.model.id == job.id)
          v.setHistoryPage(params.page) if params
        else
          app.view.remove() if app.view
          historyPage = (params && params.page) || 1
          v = app.view = new app.views.jobs.show(model: job, historyPage: historyPage).render()
          $('#main .root').html v.$el

  jobsEdit: (id) ->
    app.data.jobs.getOrFetch id, (err, job) ->
      if err
        $('#main .root').html err
      else
        app.view.remove() if app.view
        v = app.view = new app.views.jobs.edit(model: job).render()
        $('#main .root').html v.$el

  runsShow: (id, params) ->
    run = new app.models.run _id: id
    app.view.remove() if app.view
    v = app.view = new app.views.runs.show(model: run).render()
    $('#main .root').html v.$el
    run.fetch()
