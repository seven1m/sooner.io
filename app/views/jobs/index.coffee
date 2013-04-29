app.views.jobs ?= {}

class app.views.jobs.index extends Backbone.View

  initialize: ->
    @collection.on 'add', @add
    @collection.on 'reset', @reset
    @lastGroup = null
    @lastGroupId = 0

  add: (job) =>
    group = job.get('group')
    if group and group != @lastGroup
      @addGroup(group, ++@lastGroupId)
      @lastGroup = group
    job.set('groupId', group && @lastGroupId)
    view = new app.views.jobs.row(model: job).render()
    @appendRow view.$el

  addGroup: (name, groupId) =>
    view = new app.views.jobs.group_row(name: name, groupId: groupId).render()
    @appendRow view.$el

  appendRow: (html) =>
    @$el.find('tbody').append(html)

  reset: (jobs) =>
    @$el.find('tbody').empty()
    @collection.each @add

  render: ->
    @$el.html jade.render('jobs/index')
    @reset()
    @
