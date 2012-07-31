app.views.reports ?= {}

class app.views.reports.show extends Backbone.BoundView

  template: ->
    jade.render 'reports/show'

  bindings:
    _id:
      selector: '.edit-button'
      elAttribute: 'href'
      converter: (_, v) -> "/reports/#{v}/edit"
    name: '.name'
    workerName: '.workerName'
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
    @run()

  run: =>
    data =
      jobId: @model.id # it has to be 'jobId', since everything is a job on the backend
      data: @$el.find('#run-data').val()
    run = new app.models.run(data)
    run.save {},
      success: @runCreatedCallback
      error: => @$el.html 'error creating run'

  runCreatedCallback: (data) =>
    # TODO show run on same page!!!
    # (don't redirect)
    run = new app.models.run(data)
    console.log run
