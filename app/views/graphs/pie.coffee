app.views.graphs ?= {}

class app.views.graphs.pie extends Backbone.View

  className: 'graph'
  innerRadius: 35
  outerRadius: 45
  labelRadius: 55
  width: 110
  height: 110
  transitionDuration: 750

  initialize: (options) ->
    @data = options.data
    @arc = @buildArc(@innerRadius, @outerRadius)
    @labelArc = @buildArc(@labelRadius)

  dataArray: =>
    angle = 0
    total = _.reduce(v for l, v of @data, ((m, n) -> m + n), 0)
    scale = d3.scale.linear()
    scale.domain([0, total])
    for label, val of @data
      {
        l: label
        v: val
        a1: angle
        a2: angle += Math.PI * 2 * scale(val)
      }

  svg: =>
    @$el.find('svg')[0]

  buildArc: (ri, ro) =>
    ro ?= ri
    d3.svg.arc()
      .innerRadius(ri)
      .outerRadius(ro)
      .startAngle((d) -> d.a1)
      .endAngle((d) -> d.a2)

  arcTween: (d, i) =>
    int = d3.interpolateObject {v: 0, a1: 0, a2: 0}, d
    (t) =>
      @arc(int(t), i)

  labelAnchor: (d, i) =>
    if @labelArc.centroid(d)[0] < 0
      'end'
    else
      'start'

  classForDatum: (d) =>
    'misc'

  render: =>
    @$el.html '<svg></svg>'
    group = d3.select(@svg()).selectAll('circle')
      .data(@dataArray)
      .enter().append('g')
    group.append('path')
      .attr('transform', "translate(#{@width/2+1}, #{@height/2+1})")
      .attr('class', @classForDatum)
      .transition()
      .ease('cubic-in-out')
      .duration(@transitionDuration)
      .attrTween('d', @arcTween)
    #group.append('text').text((d) -> "#{d.v}%")
      #.attr('x', (d) => @labelArc.centroid(d)[0])
      #.attr('y', (d) => @labelArc.centroid(d)[1])
      #.attr('transform', (d) => "translate(#{@width/2+1}, #{@height/2+1})")
      #.attr('text-anchor', @labelAnchor)
      #.attr('dominant-baseline', 'central')
    @
