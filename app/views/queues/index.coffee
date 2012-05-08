app.views.queues ?= {}

class app.views.queues.index extends Backbone.View

  initialize: (options) ->
    @collection.on 'reset', @render

  render: =>
    @$el.html jade.render('queues/index', queues: @collection)
    @
