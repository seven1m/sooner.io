class Backbone.BoundView extends Backbone.View

  initialize: ->
    @binder = new Backbone.ModelBinder
    @model.on 'destroy', @remove

  remove: =>
    @binder.unbind()
    super()

  render: =>
    @$el.html @template()
    @binder.bind @model, @el, @bindings
    @
