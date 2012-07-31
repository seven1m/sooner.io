app.views.jobs ?= {}

class app.views.jobs.show extends Backbone.BoundView

  initialize: (options) ->
    super(options)
    # TODO put this in the job model?
    @model.history = new app.collections.runs([], job: @model, page: options.historyPage)
    @model.history.on 'error', console.log # FIXME
    @model.history.fetch()
    @list = new app.views.runs.list(collection: @model.history)

  setHistoryPage: (page) ->
    @model.history.setPage(page)
    @model.history.fetch()

  template: ->
    jade.render 'jobs/show'

  bindings:
    _id:
      selector: '.edit-button'
      elAttribute: 'href'
      converter: (_, v) -> "/jobs/#{v}/edit"
    name:
      selector: '.name'
      converter: (_, v, __, m) -> m.nameWithDisabled()
    schedule: '.schedule'
    hooks: '.hooks'
    workerName: '.workerName'
    lastStatus:
      selector: '.lastStatus'
      elAttribute: 'html'
      converter: (_, v) -> app.helpers.statusIcon(v) + ' ' + v
    lastRanAt:
      selector: '.lastRanAt'
      converter: app.converters.date_time.long
    createdAt:
      selector: '.createdAt'
      converter: app.converters.date_time.long
    updatedAt:
      selector: '.updatedAt'
      converter: app.converters.date_time.long

  events:
    'click #run-data-area .btn': 'clickRun'

  clickRun: (e) =>
    e.preventDefault()
    if @model.get('enabled') or confirm('This job is disabled. Click OK to run it anyway.')
      @run()

  run: =>
    data =
      jobId: @model.id
      data: @$el.find('#run-data').val()
    run = new app.models.run(data)
    run.save {},
      success: @runCreatedCallback
      error: => @$el.html 'error creating run'

  runCreatedCallback: (run) =>
    app.workspace.navigate "/runs/#{run.get('_id')}", trigger: yes

  render: ->
    super()
    @list.render().$el.appendTo @$el.find('#job-history')
    @
