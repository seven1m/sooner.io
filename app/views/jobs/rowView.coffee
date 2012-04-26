class app.views.jobRow extends Backbone.View

  initialize: ->
    @model.on 'change', @render

  render: =>
    @el = $(jade.render('jobs/row.jade', job: @model))[0]
    @delegateEvents();
    @
