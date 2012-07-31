class app.router extends Backbone.Router

  routes:
    '':                 'default'
    'jobs':             'jobsIndex'
    'jobs/:id':         'jobsShow'
    'jobs/:id/edit':    'jobsEdit'
    'reports':          'reportsIndex'
    'reports/:id':      'reportsShow'
    'reports/:id/edit': 'reportsEdit'
    'runs/:id':         'runsShow'
    'queues':           'queuesIndex'
    'queues/:id':       'queuesShow'
    'status':           'statusShow'

  default: ->
    @navigate 'jobs', trigger: yes

  jobsIndex: ->
    @_highlightTab 'jobs'
    app.view.remove() if app.view
    v = app.view = new app.views.jobs.index(collection: app.data.jobs).render()
    $('#main .root').html v.$el

  jobsShow: (id, params) ->
    @_highlightTab 'jobs'
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
    @_highlightTab 'jobs'
    app.data.jobs.getOrFetch id, (err, job) ->
      if err
        $('#main .root').html err
      else
        app.view.remove() if app.view
        v = app.view = new app.views.jobs.edit(model: job).render()
        $('#main .root').html v.$el

  reportsIndex: ->
    @_highlightTab 'reports'
    app.view.remove() if app.view
    v = app.view = new app.views.reports.index(collection: app.data.reports).render()
    $('#main .root').html v.$el

  reportsShow: (id, params) ->
    @_highlightTab 'reports'
    app.data.reports.getOrFetch id, (err, report) ->
      if err
        $('#main .root').html err
      else
        if (v = app.view) and (v instanceof app.views.reports.show) and (v.model.id == report.id)
          v.setHistoryPage(params.page) if params
        else
          app.view.remove() if app.view
          historyPage = (params && params.page) || 1
          v = app.view = new app.views.reports.show(model: report, historyPage: historyPage).render()
          $('#main .root').html v.$el

  reportsEdit: (id) ->
    @_highlightTab 'reports'
    app.data.reports.getOrFetch id, (err, report) ->
      if err
        $('#main .root').html err
      else
        app.view.remove() if app.view
        v = app.view = new app.views.reports.edit(model: report).render()
        $('#main .root').html v.$el

  runsShow: (id, params) ->
    @_highlightTab 'jobs'
    run = new app.models.run _id: id
    app.view.remove() if app.view
    v = app.view = new app.views.runs.show(model: run).render()
    $('#main .root').html v.$el
    run.fetch()

  queuesIndex: ->
    @_highlightTab 'queues'
    app.view.remove() if app.view
    v = app.view = new app.views.queues.index(collection: app.data.queues).render()
    $('#main .root').html v.$el

  queuesShow: (id, params) ->
    @_highlightTab 'queues'
    queue = new app.models.queue(name: id)
    unless (v = app.view) and (v instanceof app.views.queues.show) and (v.model.get('name') == queue.get('name'))
      app.view.remove() if app.view
      v = app.view = new app.views.queues.show(model: queue).render()
      $('#main .root').html v.$el
    v.setParams params

  statusShow: (id) ->
    @_highlightTab 'status'
    app.view.remove() if app.view
    v = app.view = new app.views.status.show().render()
    $('#main .root').html v.$el

  _highlightTab: (name) ->
    $('nav li').removeClass('active').filter(".#{name}").addClass('active')
