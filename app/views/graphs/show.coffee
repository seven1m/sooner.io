app.views.graphs ?= {}

class app.views.graphs.show extends Backbone.View

  className: 'graph'

  initialize: (options) ->
    @percent = options.percent

  svg: ->
    @$el.find('svg')[0]

  radians: =>
    Math.PI * 2 * @percent / 100

  render: ->
    @$el.html '<svg></svg>'
    group = d3.select(@svg()).selectAll('circle')
      .data([67])
      .enter().append('g')
    #group.append('circle')
      #.attr('cx', 50)
      #.attr('cy', 50)
      #.attr('r', 50)
      #.attr('fill', '#0088cc')
    #group.append('circle')
      #.attr('cx', 50)
      #.attr('cy', 50)
      #.attr('r', 40)
      #.attr('fill', '#fff')
    arc = d3.svg.arc()
      .innerRadius(35)
      .outerRadius(50)
      .startAngle(0)
      .endAngle(@radians)
    group.append('path')
      .transition()
      .attr('d', arc)
      .attr('transform', "translate(50, 50)")
      .attr('fill', '#0088cc')
    group.append('text').text(@percent)
      .attr('x', 50)
      .attr('y', 50)
      .attr('text-anchor', 'middle')
      .attr('dominant-baseline', 'central')
    @
