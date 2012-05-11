app.views.graphs ?= {}

class app.views.graphs.arc extends Backbone.View

  className: 'graph'
  radius: 75
  transitionDuration: 2500

  initialize: (options) ->
    @percent = Math.round(options.percent)

  svg: =>
    @$el.find('svg')[0]

  arc: ->
    d3.svg.arc()
      .innerRadius(@radius - (@radius * 0.20))
      .outerRadius(@radius)
      .startAngle(0)
      .endAngle (d) ->
        Math.PI * 2 * d / 100

  arcTween: (a, b) =>
    i = d3.interpolate b, a
    (t) =>
      @arc()(i(t))

  render: =>
    @$el.html '<svg></svg>'
    group = d3.select(@svg()).selectAll('circle')
      .data([@percent])
      .enter().append('g')
    group.append('path')
      .attr('transform', "translate(#{@radius}, #{@radius})")
      .attr('fill', '#0088cc')
      .transition()
      .ease('elastic')
      .duration(@transitionDuration)
      .attrTween('d', @arcTween)
    group.append('text').text((d) -> "#{d}%")
      .attr('x', @radius)
      .attr('y', @radius)
      .attr('text-anchor', 'middle')
      .attr('dominant-baseline', 'central')
    @
