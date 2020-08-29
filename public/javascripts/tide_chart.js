(function(){

  var margin = { top: 2, right: 0, bottom: 2, left: 0 };
  var width = 640 - margin.left - margin.right;
  var height = 60 - margin.top - margin.bottom;

  var parse_time = d3.utcParse('%Y-%m-%d %H:%M:%S %Z')
  var format_time = d3.timeFormat('%-I:%M %p');

  var x = d3.scaleTime().range( [0, width] );
  var y = d3.scaleLinear().range( [ height, 0 ] );

  var xRound = d3.scaleTime().rangeRound( x.range() );
  var yRound = d3.scaleLinear().rangeRound( y.range() );

  var line = d3.line()
        .x(function(d){ return x(d[0]); })
        .y(function(d){ return y(d[1]); })
        // .curve(d3.curveCardinal);

  var area = d3.area()
        .x(function(d){ return x(d[0]); })
        .y0( height )
        .y1(function(d){ return y(d[1]); })
        // .curve(d3.curveCardinal);

  var svg = d3.select('#tide-chart')
        .append('svg')
          .attr('width',  width + margin.left + margin.right )
          .attr('height', height + margin.top + margin.bottom )
        .append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  var chart = svg.append('g')
    .attr('class', 'chart');

  var events = svg.append('g')
    .attr('class', 'events');

  d3.json('/tide.json').then((data) => {
    // Parse all timestamps into Dates
    data.start = parse_time( data.start );
    data.end = parse_time( data.end );
    data.now[0] = parse_time( data.now[0] );
    data.events.forEach( function(d){ d[0] = parse_time( d[0] ) });
    data.graph.forEach(  function(d){ d[0] = parse_time( d[0] ) });

    // Set up scale domains now that we know the data
    x.domain( [ data.start, data.end ] );
    y.domain( d3.extent( data.graph, function(d){ return d[1]; } ) );

    xRound.domain( x.domain() );
    yRound.domain( y.domain() );

    // Draw the chart
    chart.append('path')
      .datum( data.graph )
      .attr('class', 'area')
      .attr('d', area );

    chart.append('path')
      .datum( data.graph )
      .attr('class', 'line')
      .attr('d', line );

    // Indicators for high and low tide events
    events.selectAll('circle')
      .data( data.events )
      .enter().append('circle')
        .attr('r', 1)
        .attr('cx', function(d){ return xRound(d[0]); })
        .attr('cy', function(d){ return yRound(d[1]); });

    events.selectAll('text')
      .data( data.events )
      .enter().append('text')
        .attr('x', function(d){ return xRound(d[0]); })
        .attr('y', function(d){ return yRound(d[1]); })
        .attr('dy',function(d){ return (d[2] == 'High Tide') ? '14px' : '-6px'; } )
        .attr('text-anchor', 'middle')
        .text( function(d){ return format_time(d[0]); });

    // Indicator for current time
    svg.append('circle')
      .attr('class', 'now')
      .attr('cx', xRound(data.now[0]) )
      .attr('cy', yRound(data.now[1]) )
      .attr('r', 2 );
  });

})();
