app.views.jobs ?= {}

class app.views.jobs.group_row extends Backbone.View

  events:
    click: 'expandGroup'

  tagName: 'tr'

  template: =>
    $(jade.render 'jobs/group_row').html()

  render: =>
    @$el
      .html(@template())
      .addClass('group-row')
      .attr('id', "group-#{@options.groupId}")
      .find('.name').html(@options.name)
    @

  expandGroup: =>
    @$el.find('i').toggleClass ->
      if $(this).hasClass('icon-plus')
        'icon-minus'
      else
        'icon-plus'
    $(".group-#{@options.groupId}").toggle()
