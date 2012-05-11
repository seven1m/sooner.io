app.views.dashboard ?= {}

class app.views.dashboard.show extends Backbone.View

  template: ->
    jade.render 'dashboard/show'

  refresh: ->
    g = new app.views.graphs.show(percent: 75)
    @$el.find('#graphs').append g.render().$el

  render: ->
    @$el.html jade.render('dashboard/show')
    @refresh()
    @
