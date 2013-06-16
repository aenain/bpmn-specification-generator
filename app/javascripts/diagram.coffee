root = exports ? this
root.Diagram = Diagram = {}

class Diagram.Font
  constructor: (options = {}) ->
    @size = options.size || 12 # pixels
    @lineHeight = options.lineHeight || 1.4 * @size
    @family = 'Arial'
    @color = 'black'

class Diagram.Measurer
  constructor: (@drawer) ->

  getTextWidth: (text, style) ->
    @drawer.measureText(text, style).width

class Diagram.Shape
  @STYLES =
    activity:
      fill:
        color: 'yellow'
      stroke:
        width: 2
        color: 'black'
    start_event:
      fill:
        color: 'green'
      stroke:
        width: 2
        color: 'black'
    end_event:
      fill:
        color: 'red'
      stroke:
        width: 2
        color: 'black'
    matched_fragment:
      fill:
        color: 'rgba(0, 0, 0, 0.02)'
      stroke:
        width: 0
        color: 'white'
    sub_process:
      fill:
        color: '#eee'
      stroke:
        width: 2
        color: '#000'
    gateway:
      fill:
        color: 'pink'
      stroke:
        width: 2
        color: '#000'

  constructor: (@box, @type) ->
    @style = Diagram.Shape.STYLES[@type]
    @context = null
    @center =
      top: @box.top + Math.round(@box.height / 2)
      left: @box.left + Math.round(@box.width / 2)

  getBoundaries: ->
    {
      left: @box.left
      top: @box.top
      right: @box.left + @box.width
      bottom: @box.top + @box.height
    }

  getCenter: ->
    @center

  getSize: ->
    {
      width: @box.width
      height: @box.height
    }

class Diagram.Label
  @STYLES =
    horizontalAlign: "center"
    verticalAlign: "middle"

  constructor: (@text, @font) ->
    @lines = [@text]
    @position =
      top: 0
      left: 0

    @measurer = null
    @style = _.extend({}, Diagram.Label.STYLES, @font)

  setMeasurer: (measurer) ->
    @measurer = measurer

  placeInside: (boundaries) ->
    width = boundaries.right - boundaries.left
    @splitTextToFit(width)
    @centerInside(boundaries)

  placeUnder: (boundaries) ->
    @centerUnder(boundaries)

  splitTextToFit: (boxWidth) ->
    words = @text.split(' ')
    @lines = []
    line = ''

    for word in words
      testLine = line + word + ' '
      lineWidth = @measurer.getTextWidth(testLine, @style)
      if lineWidth >= boxWidth
        @lines.push(line.trim())
        line = word + ' '
      else
        line = testLine

    @lines.push(line.trim())

    @lines

  centerInside: (boundaries) ->
    center = @getCenterOf(boundaries)
    @position.top = center.top - ((@lines.length - 1) / 2) * @font.lineHeight
    @position.left = center.left

  centerUnder: (boundaries) ->
    center = @getCenterOf(boundaries)
    @position.top = boundaries.bottom + @font.lineHeight
    @position.left = center.left

  getCenterOf: (boundaries) ->
    center =
      left: Math.round((boundaries.left + boundaries.right) / 2)
      top: Math.round((boundaries.top + boundaries.bottom) / 2)

class Diagram.Path
  @STYLES =
    stroke:
      width: 2
      color: 'black'

  constructor: (@waypoints) ->
    @style = Diagram.Path.STYLES

class Diagram.Model
  constructor: (@canvas, @data) ->
    @drawer = null # we have to resize canvas first

  init: ->
    @resizeCanvas()
    @createDrawer()

  drawElements: ->
    @drawNodes()
    @drawConnectors()

  resizeCanvas: ->
    @canvas.width = @data.width
    @canvas.height = @data.height

  createDrawer: ->
    @drawer = new Diagram.Drawer(@canvas)

  drawNodes: ->
    for node in @data.nodes
      switch node.class
        when 'Task'             then @drawer.drawActivity(node.position, node.label)
        when 'StartEvent'       then @drawer.drawStartEvent(node.position, node.label)
        when 'EndEvent'         then @drawer.drawEndEvent(node.position, node.label)
        when 'Gateway'          then @drawer.drawGateway(node.position, node.label)
        when 'SubProcess'       then @drawer.drawSubProcess(node.position, node.label)
        when 'MatchedFragment'  then @drawer.drawMatchedFragment(node.position, node.label)

  drawConnectors: ->
    for connector in @data.connectors
      switch connector.type
        when 'sequence_flow'  then @drawer.drawConnector(connector.waypoints, connector.label)

class Diagram.Drawer
  constructor: (@canvas) ->
    @context = @canvas.getContext('2d')
    @font = new Diagram.Font()
    @measurer = new Diagram.Measurer(this)

    @style =
      active: null
      previous: null

  #
  # @param position Object(top, left, width, height)
  # @param text String
  #
  drawActivity: (position, text) ->
    shape = new Diagram.Shape(position, 'activity')
    label = new Diagram.Label(text, @font)
    label.setMeasurer(@measurer)
    label.placeInside(shape.getBoundaries())

    @drawRectangle(shape)
    @drawLabel(label)

  #
  # @param position Object(top, left, width, height)
  # @param text String
  #
  drawStartEvent: (position, text) ->
    shape = new Diagram.Shape(position, 'start_event')
    label = new Diagram.Label(text, @font)
    label.setMeasurer(@measurer)
    label.placeUnder(shape.getBoundaries())

    @drawCircle(shape)
    @drawLabel(label)

  #
  # @param position Object(top, left, width, height)
  # @param text String
  #
  drawEndEvent: (position, text) ->
    shape = new Diagram.Shape(position, 'end_event')
    label = new Diagram.Label(text, @font)
    label.setMeasurer(@measurer)
    label.placeUnder(shape.getBoundaries())

    @drawCircle(shape)
    @drawLabel(label)

  #
  # @param position Object(top, left, width, height)
  # @param text String
  #
  drawMatchedFragment: (position, text) ->
    shape = new Diagram.Shape(position, 'matched_fragment')
    label = new Diagram.Label(text, @font)
    label.setMeasurer(@measurer)
    label.placeUnder(shape.getBoundaries())

    @drawRectangle(shape)
    @drawLabel(label)

  #
  # @param position Object(top, left, width, height)
  # @param text String
  #
  drawSubProcess: (position, text) ->
    shape = new Diagram.Shape(position, 'sub_process')
    label = new Diagram.Label(text, @font)
    label.setMeasurer(@measurer)
    # TODO! place under top edge
    label.placeUnder(shape.getBoundaries())

    @drawRectangle(shape)
    @drawLabel(label)

  #
  # @param position Object(top, left, width, height)
  # @param text String
  #
  drawGateway: (position, text) ->
    shape = new Diagram.Shape(position, 'gateway')
    label = new Diagram.Label(text, @font)
    label.setMeasurer(@measurer)
    label.placeUnder(shape.getBoundaries())

    @drawRuby(shape)
    @drawLabel(label)


  #
  # @param waypoints [Object(top, left)]
  # @param text String
  #
  drawConnector: (waypoints, text) ->
    path = new Diagram.Path(waypoints)
    # label = new Diagram.Label(text, @font)
    @drawPath(path)
    # @drawLabel(label)

  #
  # @param shape Diagram.Shape
  # @param callback callback that gets styled context as the only argument
  #
  drawRuby: (shape, callback) ->
    @withOpenPath shape.style, (context) ->
      bounds = shape.getBoundaries()
      center = shape.getCenter()

      context.moveTo(center.left, bounds.top)
      context.lineTo(bounds.right, center.top)
      context.lineTo(center.left, bounds.bottom)
      context.lineTo(bounds.left, center.top)
      context.lineTo(center.left, bounds.top)

      callback(context) if callback?

  #
  # @param shape Diagram.Shape
  # @param callback callback that gets styled context as the only argument
  #
  drawRectangle: (shape, callback) ->
    @withOpenPath shape.style, (context) ->
      context.rect(shape.box.left, shape.box.top, shape.box.width, shape.box.height) 
      callback(context) if callback?                       

  #
  # @param shape Diagram.Shape
  # @param callback callback that gets styled context as the only argument
  #
  drawCircle: (shape, callback) ->
    @withOpenPath shape.style, (context) ->
      context.arc(shape.center.left, shape.center.top, Math.round(shape.box.width / 2), 0, 2 * Math.PI, false)
      callback(context) if callback?

  #
  # @param label Diagram.Label
  #
  drawLabel: (label) ->
    @setTextStyle(label.style)
    linePosition = label.position

    for line in label.lines
      @context.fillText(line, linePosition.left, linePosition.top)
      linePosition.top += label.style.lineHeight

  #
  # @param path Diagram.Path
  #
  drawPath: (path) ->
    startPoint = path.waypoints.shift()
    endPoint = path.waypoints[path.waypoints.length - 1]
    angle = 0
    headLength = 7

    @withOpenPath path.style, (context) =>
      context.moveTo(startPoint.left, startPoint.top)
      previousPoint = startPoint

      for waypoint in path.waypoints
        angle = Math.atan2(waypoint.top - previousPoint.top, waypoint.left - previousPoint.left)
        context.lineTo(waypoint.left, waypoint.top)
        previousPoint = waypoint

      # draw arrow (http://stackoverflow.com/questions/808826/draw-arrow-on-canvas-tag#answer-6333775)
      context.lineTo(endPoint.left - headLength * Math.cos(angle-Math.PI/6), endPoint.top - headLength * Math.sin(angle-Math.PI/6))
      context.moveTo(endPoint.left, endPoint.top)
      context.lineTo(endPoint.left - headLength * Math.cos(angle+Math.PI/6), endPoint.top - headLength * Math.sin(angle+Math.PI/6))

  withOpenPath: (style, callback) ->
    @context.beginPath()
    @setStyle(style)
    callback(@context) if callback?
    @context.fill() if @style.active.fill?
    @context.stroke() if @style.active.stroke?
    @context.closePath()

  measureText: (text, style) ->
    @setTextStyle(style)
    metrics = @context.measureText(text)
    @restorePreviousStyle(style)

    metrics

  setTextStyle: (style) ->
    @setStyle({ text: style })

  setStyle: (style) ->
    @storePreviousStyle()
    @setActiveStyle(style)
    @applyStyle()

  restorePreviousStyle: ->
    @setStyle(@style.previous) if @style.previous?

  storePreviousStyle: ->
    @style.previous = @style.active

  setActiveStyle: (style) ->
    @style.active = style

  applyStyle: ->
    @resetStyle()

    if @style.active.stroke?
      @context.lineWidth = @style.active.stroke.width
      @context.strokeStyle = @style.active.stroke.color

    if @style.active.fill?
      @context.fillStyle = @style.active.fill.color

    if @style.active.text?
      @context.font = "#{@style.active.text.size}px #{@style.active.text.family}"
      @context.textAlign = @style.active.text.horizontalAlign
      @context.textBaseline = @style.active.text.verticalAlign
      @context.fillStyle = @style.active.text.color

  resetStyle: ->
    @context.lineWidth = 1
    @context.strokeStyle = "#000000"
    @context.fillStyle = "#000000"
    @context.font = ""
    @context.textAlign = "left"
    @context.textBaseline = "middle"