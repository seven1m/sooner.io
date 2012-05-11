app.views.queues ?= {}

class app.views.queues.index extends Backbone.View

  initialize: (options) ->
    @collection.on 'reset', @render

  template: =>
    jade.render('queues/index')

  refresh: =>
    root = @$el.find('#queues').empty()
    @collection.each (queue) =>
      view = new app.views.queues.row(model: queue).render()
      root.append view.$el

  render: =>
    @$el.html @template()
    @refresh()
    @
