class SVGDraw

  class State
    constructor: (context)->
      @context = context
    onMouseDown: (e)->
    onMouseUp: (e)->
    onMouseMove: (e)->
    onMouseLeave: (e)->

  class WaitingState extends State
    onMouseDown: (e)->
      @context.status = new DrawingState(@context)
    onMouseMove: (e)->
      console.log 'waiting'

  class DrawingState extends State
    line_id_counter: 0

    constructor: (context)->
      super
      @line = new Line(id: ++@line_id_counter)
      @line.addPoint(@context.getMousePosition())
      @context.addLine(@line)

    onMouseMove: (e)->
      @line.addPoint(@context.getMousePosition())
      @context.updateLine(@line)

    onMouseUp: (e)->
      console.log @line.points
      @context.closeLine(@line)
      @context.status = new WaitingState(@context)

    onMouseLeave: (e)->
      @context.closeLine(@line)
      @context.status = new WaitingState(@context)      

  line_color: '#000000'
  line_width: 1
  background_color: 'blue'
  zoom: 1
  event_listeners: {}
  lines: []

  constructor: (params)->
    {@width, @height, @el} = params
    @width ||= 640
    @height ||= 480
    unless @el
      throw Error('el is required')
    @selection = d3.select(@el)
    @svg = d3.select(@el)[0][0]
    if @svg.nodeName != 'svg'
      throw Error('el must specify a svg element.')
    @status = new WaitingState(@)
    @_initCanvas()

  _initCanvas: ->
    d3.select(@el)
    .attr('width', "#{@width}px")
    .attr('height', "#{@height}px")
    .style('display', 'inline-block')
    .style('background-color', @background_color)
    .on('mousedown', (e)=> @onMouseDown(e))
    .on('mousemove', (e)=> @onMouseMove(e))
    .on('mouseup', (e)=> @onMouseUp(e))
    .on('mouseleave', (e)=> @onMouseLeave(e))

  getMousePosition: ->
    d3.mouse(@svg)

  onMouseDown: (e)->
    @status.onMouseDown(e)

  onMouseUp: (e)->
    @status.onMouseUp(e)

  onMouseMove: (e)->
    @status.onMouseMove(e)

  onMouseLeave: (e)->
    @status.onMouseLeave(e)

  setLineColor: (line_color)->
    @line_color = line_color

  setLineWidth: (line_width)->
    @line_width = line_width

  setBackgroundColor: (background_color)->
    @background_color = background_color

  setImage: (image_url)->
    @image_url = image_url
    @selection.insert('image', ':first-child')
    .attr('xlink:href', image_url)
    .attr('width', @width)
    .attr('height', @height)

  clearImage: ->
    @image_url = null
    @selection.selectAll('image').remove()

  on: (event, f)->
    unless @event_listeners[event]
      @event_listeners[event] = []
    @event_listeners[event].push(f)

  off: (event, f)->
    listeners = @event_listeners[event]
    if listeners?
      idx = listeners.indexOf(f)
      if idx >= 0
        listeners.splice(idx, 1)

  addLine: (line)->
    @lines.push(line)
    @pen = d3.svg.line().interpolate('cardinal')
    data = @pen(line.points)
    @current_line = @selection.append('path')
    .attr('data-line_id', line.id)
    .attr('d', data)
    .attr('fill', 'transparent')
    .attr('stroke', line.color)

  updateLine: (line)->
    if @current_line && @pen
      data = @pen(line.points)
      @current_line.attr('d', data)

  closeLine: (line)->
    if @current_line && @pen
      data = @pen(line.points)
      @current_line.attr('d', data)      

  class Line
    color: '#000000'
    width: 1

    constructor: (params)->
      {@id} = params
      @points = []
      @color = params.color if params.color
      @width = params.width if params.width

    addPoint: (point)->
      @points.push(point)
