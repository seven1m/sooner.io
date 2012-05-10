app.views.jobs ?= {}

class app.views.jobs.edit extends Backbone.BoundView

  template: ->
    jade.render 'jobs/edit'

  bindings:
    name: '#name'
    path: '#path'
    enabled:
      selector: '#enabled'
      elAttribute: 'checked'
    schedule: '#schedule'
    hooks: '#hooks'
    workerName: '#workerName'
    mutex:
      selector: '#mutex'
      elAttribute: 'checked'

  render: ->
    super()
    @$el.find('#save').click (e) =>
      e.preventDefault()
      @$el.find('fieldset').removeClass('errors')
      @$el.find('.control-group').removeClass('error')
      @model.save {}, success: =>
        app.workspace.navigate "/jobs/#{@model.id}", trigger: yes
      , error: (_, res) =>
        @$el.find('fieldset').addClass('errors')
        for attr of res.errors
          @$el.find('#' + attr).parents('.control-group').addClass('error')
    @
