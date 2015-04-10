(function(){

  var margin = { top: 2, right: 0, bottom: 2, left: 0 };
  var width = 640 - margin.left - margin.right;
  var height = 60 - margin.top - margin.bottom;

  var parse_time = d3.time.format.utc('%Y-%m-%d %H:%M:%S %Z').parse;
  var format_time = d3.time.format('%-I:%M %p');

  var x = d3.time.scale().range( [0, width] );
  var y = d3.scale.linear().range( [ height, 0 ] );

  var line = d3.svg.line()
        .x(function(d){ return x(d[0]); })
        .y(function(d){ return y(d[1]); })
        .interpolate('cardinal');

  var area = d3.svg.area()
        .x(function(d){ return x(d[0]); })
        .y0( height )
        .y1(function(d){ return y(d[1]); })
        .interpolate('cardinal');

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

  d3.json( '/tide.json', function( err, data ) {

    // Parse all timestamps into Dates
    data.start = parse_time( data.start );
    data.end = parse_time( data.end );
    data.now[0] = parse_time( data.now[0] );
    data.events.forEach( function(d){ d[0] = parse_time( d[0] ) });
    data.graph.forEach(  function(d){ d[0] = parse_time( d[0] ) });

    // Set up scale domains now that we know the data
    x.domain( [ data.start, data.end ] );
    y.domain( d3.extent( data.graph, function(d){ return d[1]; } ) );

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
        .attr('cx', function(d){ return x(d[0]); })
        .attr('cy', function(d){ return y(d[1]); });

    events.selectAll('text')
      .data( data.events )
      .enter().append('text')
        .attr('x', function(d){ return x(d[0]); })
        .attr('y', function(d){ return y(d[1]); })
        .attr('dy',function(d){ return (d[2] == 'High Tide') ? '14px' : '-6px'; } )
        .attr('text-anchor', 'middle')
        .text( function(d){ return format_time(d[0]); });

    // Indicator for current time
    svg.append('circle')
      .attr('class', 'now')
      .attr('cx', x(data.now[0]) )
      .attr('cy', y(data.now[1]) )
      .attr('r', 2 );

  });

})();
