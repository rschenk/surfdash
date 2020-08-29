Sparkline = function(containerSelector, data) {
  const margin = { top: 0, right: 0, bottom: 1, left: 0 };
  const width = 300 - margin.left - margin.right;
  const height = 25 - margin.top - margin.bottom;

  const parseTime = d3.utcParse('%Y-%m-%d %H:%M:%S %Z');

  // Parse timestamps into Dates
  data.forEach(d => { d[0] = parseTime(d[0]) })

  const x = d3.scaleTime()
    .domain( d3.extent(data, d => d[0]) )
    .range( [0, width] )
    .interpolate(d3.interpolateRound);

  const y = d3.scaleLinear()
    .domain( d3.extent(data, d => d[1]) )
    .range( [ height, 0 ] )
    .interpolate(d3.interpolateRound);

  const line = d3.line()
    .x(d => x(d[0]))
    .y(d => y(d[1]))

  const axis = d3.axisBottom(x)
    .ticks(d3.timeDay)
    .tickSize(height)

  let svg = d3.select(containerSelector)
    .append('svg')
      .attr('width',  width + margin.left + margin.right )
      .attr('height', height + margin.top + margin.bottom )
    .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  svg.append('g')
    .attr('class', 'axis')
    .call(axis)
    .call(g => g.select(".domain").remove())
    .call(g => g.selectAll(".tick text").remove())

  let chart = svg.append('g')
    .attr('class', 'chart')
    .attr('transform', 'translate(0.5, 0.5)'); // Trick for sharp 1px line rendering

  chart.append('path')
    .datum(data)
    .attr('class', 'line')
    .attr('d', line)
}
