class app.views.jobList extends Backbone.View

  initialize: ->
    @collection = new app.collections.jobs
    @collection.on 'add', @addJob
    @collection.on 'remove', @removeJob
    @collection.on 'change', @change
    @collection.on 'reset', @reset

  addJob: (job) =>
    console.log 'add', job

  removeJob: (job) =>
    console.log 'remove', job

  change: (jobs) =>
    console.log 'change', jobs

  reset: (jobs) =>
    @collection.each (job) =>
      view = new app.views.jobRow(model: job).render()
      @$el.find('tbody').append view.$el

  id: 'job-list'

  render: ->
    @$el.html jade.render('jobs/list.jade')
    @collection.fetch()
    @
