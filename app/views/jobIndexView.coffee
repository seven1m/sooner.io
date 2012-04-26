class app.views.jobIndex extends Backbone.View

  initialize: ->
    @list = new app.views.jobList

  id: 'job-index'

  render: ->
    @$el.html jade.render('jobs/index.jade')
    @list.render().$el.appendTo @$el.find('#job-list-container')
    @
