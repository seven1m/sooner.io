class app.views.jobList extends Backbone.View

  collection: new app.collections.jobs

  id: 'job-list'

  render: ->
    @$el.html jade.render('jobs/list.jade')
    @
