app.views.reports ?= {}

class app.views.reports.edit extends Backbone.BoundView

  template: ->
    jade.render 'reports/edit'

  bindings:
    name: '#name'
    path: '#path'
    workerName: '#workerName'

  render: ->
    super()
    @$el.find('#save').click (e) =>
      e.preventDefault()
      @$el.find('fieldset').removeClass('errors')
      @$el.find('.control-group').removeClass('error')
      @model.save {}, success: =>
        app.workspace.navigate "/reports/#{@model.id}", trigger: yes
      , error: (_, res) =>
        @$el.find('fieldset').addClass('errors')
        for attr of res.errors
          @$el.find('#' + attr).parents('.control-group').addClass('error')
    @
