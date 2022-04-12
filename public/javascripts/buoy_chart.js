const BuoyChart = (containerSelector, data) => {
  const selection = d3.select(containerSelector)
  const globalMargin = { top: 0, right: 0, bottom: 14, left: 0 }
  const margin = { top: 2, right: 6, bottom: 2, left: 2 }
  const width = 300
  const chartHeight = 30 + margin.top + margin.bottom
  const height = (chartHeight + margin.top + margin.bottom) * 2

  const parseTime = d3.utcParse('%Y-%m-%d %H:%M:%S %Z')

  // Parse timestamps into Dates
  data.forEach(d => d[0] = parseTime(d[0]))

  const lastDatum = data[data.length - 1]

  const x = d3.scaleTime()
    .domain(d3.extent(data, d => d[0]))
    .range([margin.left, width - margin.right])
    .interpolate(d3.interpolateRound)

  const heightY = d3.scaleLinear()
    .domain(d3.extent(data, d => d[1]))
    .range([chartHeight - margin.top - margin.bottom, margin.top])
    .interpolate(d3.interpolateRound)

  const periodY = d3.scaleLinear()
    .domain(d3.extent(data, d => d[2]))
    .range([chartHeight - margin.top - margin.bottom, margin.top])
    .interpolate(d3.interpolateRound)

  const midnightTickmarksAxis = d3.axisBottom(x)
    .ticks(d3.timeDay)
    .tickSize(height)
    .tickFormat('') // no labels

  const dayLabelsAxis = d3.axisBottom(x)
    .ticks(d3.timeHour, 12) // ticks at noon and midnight
    .tickSize(0) // no actual tickmarks
    .tickFormat(dayTickFormat)

  const heightLine = d3.line()
    .x(d => x(d[0]))
    .y(d => heightY(d[1]))

  const periodLine = d3.line()
    .x(d => x(d[0]))
    .y(d => periodY(d[2]))

  const waveHeightVal = selection.select('.metric.wave-height .value')
  const dPeriodVal = selection.select('.metric.dominant-period .value')
  const aPeriodVal = selection.select('.metric.average-period .value')
  const directionVal = selection.select('.metric.direction .value')
  const timeVal = selection.select('.metric.time .value')

  const svg = selection
    .append('svg')
    .attr('class', 'buoy--charts')
    .attr('viewBox', [0, 0, width, height + (globalMargin.top + globalMargin.bottom)])
    // Uncomment below for fixed size
    .attr('width', width)
    .attr('height', height)

  const axisWrapper = svg.append('g')
    .attr('class', 'axisWrapper')
    .attr('transform', `translate(${margin.left}, 0)`)

  const _tickAxis = axisWrapper.append('g')
    .attr('class', 'axis axis--x')
    .call(midnightTickmarksAxis)
    .call(g => g.select('.domain').remove())
    .call(g => g.selectAll('.tick text').remove())

  const _labelAxis = axisWrapper.append('g')
  .attr('class', 'axis axis--x')
  .attr('transform', `translate(0, ${height})`)
  .call(dayLabelsAxis)
  .call(g => g.select('.domain').remove())

  const heightChartWrapper = svg.append('g')
    .attr('class', 'chartWrapper')
    .attr('transform', `translate(${margin.left}, ${margin.top})`)

  const heightChart = heightChartWrapper.append('g')
    .attr('class', 'chart chart--height')
    .attr('transform', 'translate(0.5, 0.5)') // Trick for sharp 1px line rendering

  heightChart.append('path')
    .datum(data)
    .attr('class', 'line')
    .attr('d', heightLine)

  const periodChartWrapper = svg.append('g')
    .attr('class', 'chartWrapper')
    .attr('transform', `translate(${margin.left}, ${chartHeight + margin.top + margin.bottom})`)

  const periodChart = periodChartWrapper.append('g')
    .attr('class', 'chart chart--period')
    .attr('transform', 'translate(0.5, 0.5)') // Trick for sharp 1px line rendering

  periodChart.append('path')
    .datum(data)
    .attr('class', 'line')
    .attr('d', periodLine)

  const heightPointMarker = heightChartWrapper.append('circle')
    .attr('class', 'point-marker point-marker--height')
    .attr('r', 2)
    .attr('transform', 'translate(0.5, 0.5)') // undo the sharp line trick

  const periodPointMarker = periodChartWrapper.append('circle')
    .attr('class', 'point-marker point-marker--period')
    .attr('r', 2)
    .attr('transform', 'translate(0.5, 0.5)') // undo the sharp line trick

  /* Helpers */
  function isToday(date) {
    const today = new Date()
    return(
      date.getDate() === today.getDate() &&
      date.getMonth() === today.getMonth() &&
      date.getYear() === today.getYear()
    )
  }

  function isYesterday(date) {
    let clone = new Date(date.getTime())
    clone.setDate(date.getDate() + 1)
    return isToday(clone)
  }

  function isThisWeek(date) {
    let lastWeek = new Date()
    lastWeek.setDate(lastWeek.getDate() - 7)
    return date > lastWeek
  }

  function dayTickFormat(date) {
    // Draw label only at noon
    if (date.getHours() !== 12) { return null }
    if(isToday(date)) { return "today" }
    if(isYesterday(date)) { return "yesterday" }

    let formatter;

    if(isThisWeek(date)) {
      formatter = d3.timeFormat('%A')
    } else {
      formatter = d3.timeFormat('%a %d')
    }

    return formatter(date).toString().toLowerCase()
  }

  /* Interactivity */

  // Binary search function to look up closet data point to a given date
  const bisectDate = d3.bisector(row => row[0])
  const findNearestDataPoint = (bisector, data, date) => {
    const i = bisector.left(data, date, 1, data.length - 1)
    const a = data[i - 1]
    const b = data[i]
    return date - a[0] > b[0] - date ? b : a
  }
  const formatTime = (t) => {
    const today = d3.timeFormat("%-I:%M %p")

    return today(t)
  }

  const setMetrics = ([time, waveH, dPeriod, aPeriod, dir]) => {
    waveHeightVal.text( Math.round(waveH * 10) / 10)
    dPeriodVal.text( Math.round(dPeriod) )
    aPeriodVal.text( Math.round(aPeriod) )
    directionVal.text( dir )
    timeVal.text( formatTime(time) )

    heightPointMarker
      .attr('display', null)
      .attr('cx', x(time))
      .attr('cy', heightY(waveH))

    periodPointMarker
      .attr('display', null)
      .attr('cx', x(time))
      .attr('cy', periodY(dPeriod))
  }

  svg.on('mousemove click touchmove', function () {
    const mouseCoords = d3.mouse(this)
    const mouseDate = x.invert(mouseCoords[0])
    const nearestDataPoint = findNearestDataPoint(bisectDate, data, mouseDate)

    setMetrics(nearestDataPoint)
  })

  svg.on('mouseleave', event => {
    setMetrics(lastDatum)
  })

  setMetrics(lastDatum)
}
