app.views.graphs ?= {}

class app.views.graphs.column extends Backbone.View

  className: 'graph'
  colWidth: 20
  colGutter: 10
  width: 110
  height: 110
  transitionDuration: 750

  initialize: (options) ->
    @data = options.data

  svg: =>
    @$el.find('svg')[0]

  #colTween: (d, i) =>
    #int = d3.interpolate 0, d
    #(t) =>
      #@arc(int(t), i)

  render: =>
    @$el.html '<svg></svg>'
    group = d3.select(@svg()).selectAll('')
      .data(@dataArray)
      .enter().append('g')

    # data arcs
    group.append('path')
      .attr('transform', "translate(#{@width/2+1}, #{@height/2+1})")
      .attr('class', (d) -> "misc #{d.c}")
      .transition()
      .ease('cubic-in-out')
      .duration(@transitionDuration)
      .attrTween('d', @arcTween)

    ## labels
    #group.append('text').text((d) -> "#{d.v}%")
      #.attr('x', (d) => @labelArc.centroid(d)[0])
      #.attr('y', (d) => @labelArc.centroid(d)[1])
      #.attr('transform', (d) => "translate(#{@width/2+1}, #{@height/2+1})")
      #.attr('text-anchor', @labelAnchor)
      #.attr('dominant-baseline', 'central')

    @
