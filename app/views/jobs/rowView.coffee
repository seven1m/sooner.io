class app.views.jobRow extends Backbone.View

  initialize: ->
    @model.on 'change', @render

  template: ->
    $(jade.render('jobs/row', job: @model.attributes)).html()

  tagName: 'tr'

  render: =>
    @$el.html @template()
    @
