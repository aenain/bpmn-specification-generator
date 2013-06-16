root = exports ? this
root.Diagram = Diagram = {}

class Diagram.Font
  constructor: (@options = {}) ->
    @size = @options.size || 12 # pixels
    @lineHeight = @options.lineHeight || 1.4 * @size
    @family = 'Arial'
    @color = '#777'

  copy: ->
    new Diagram.Font(@options)

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
        width: 1
        color: '#777'
    start_event:
      fill:
        color: 'green'
      stroke:
        width: 1
        color: 'black'
    end_event:
      fill:
        color: 'red'
      stroke:
        width: 1
        color: 'black'
    matched_fragment:
      fill:
        color: 'rgba(0, 0, 0, 0.03)'
      stroke:
        width: 1
        color: 'rgba(0, 0, 0, 0.03)'
    sub_process:
      fill:
        color: 'rgba(0, 0, 255, 0.1)'
      stroke:
        width: 1
        color: 'rgba(0, 0, 255, 0.1)'
    gateway:
      fill:
        color: 'pink'
      stroke:
        width: 1
        color: 'rgba(0, 0, 0, 0.4)'

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

  placeUnderTop: (boundaries) ->
    @centerUnderTop(boundaries)

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

  centerUnderTop: (boundaries) ->
    center = @getCenterOf(boundaries)
    @position.top = boundaries.top + @font.lineHeight
    @position.left = center.left

  getCenterOf: (boundaries) ->
    center =
      left: Math.round((boundaries.left + boundaries.right) / 2)
      top: Math.round((boundaries.top + boundaries.bottom) / 2)

class Diagram.Path
  @STYLES =
    stroke:
      width: 1
      color: '#000'

  constructor: (@waypoints) ->
    @style = Diagram.Path.STYLES

class Diagram.InfoManager
  constructor: (@element) ->
    # nothing for now.

  #
  # @param info String - text to display
  #
  update: (info) ->
    @element.innerText = info

class Diagram.FragmentHover
  constructor: () ->
    @fragments = []

  bind: (model) ->
    @storeFragments(model.data.nodes) unless @fragments.count
    @bindToCanvas model.canvas, (fragment) ->
      model.onFragmentHover(fragment)

  storeFragments: (nodes) ->
    for node in nodes
      @fragments.push(node) if node.class == 'MatchedFragment'

    # the more general fragment, the later should be asked if hovered
    @fragments.reverse()

  #
  # @param canvas HTMLElement
  # @param callback Function - will be called on fragment hover
  #
  bindToCanvas: (canvas, callback) ->
    canvas.addEventListener 'mousemove', (event) =>
      position = @positionInside(event, canvas)

      for fragment in @fragments
        if @isHovered(fragment, position)
          callback(fragment)
          break

  positionInside: (mouseEvent, domElement) ->
    rectangle = domElement.getBoundingClientRect()

    {
      top: mouseEvent.clientY - rectangle.top,
      left: mouseEvent.clientX - rectangle.left
    }

  isHovered: (fragment, position) ->
    position.left >= fragment.position.left &&
    position.top  >= fragment.position.top &&
    position.left <= fragment.position.left + fragment.position.width &&
    position.top  <= fragment.position.top + fragment.position.height

class Diagram.Model
  constructor: (@canvas, @infoElement, @data) ->
    @drawer = null # we have to resize canvas first
    @info = null

  init: ->
    @resizeCanvas()
    @createDrawer()
    @createInfoManager()

    @drawElements()
    @bindEvents()

  drawElements: ->
    @drawNodes()
    @drawConnectors()

  bindEvents: ->
    new Diagram.FragmentHover().bind(this)

  resizeCanvas: ->
    @canvas.width = @data.width
    @canvas.height = @data.height

  createDrawer: ->
    @drawer = new Diagram.Drawer(@canvas)

  createInfoManager: ->
    @info = new Diagram.InfoManager(@infoElement)

  onFragmentHover: (fragment) ->
    @info.update(fragment.label)

  drawNodes: ->
    for node in @data.nodes
      switch node.class
        when 'Task'             then @drawer.drawActivity(node.position, node.label)
        when 'StartEvent'       then @drawer.drawStartEvent(node.position, node.label)
        when 'EndEvent'         then @drawer.drawEndEvent(node.position, node.label)
        when 'Gateway'          then @drawer.drawGateway(node.type, node.position, node.label)
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
    # label = new Diagram.Label(text, @font)
    # label.setMeasurer(@measurer)
    # label.placeUnder(shape.getBoundaries())

    @drawRectangle(shape)
    # @drawLabel(label)

  #
  # @param position Object(top, left, width, height)
  # @param text String
  #
  drawSubProcess: (position, text) ->
    shape = new Diagram.Shape(position, 'sub_process')
    label = new Diagram.Label(text, @font)
    label.setMeasurer(@measurer)
    label.placeUnderTop(shape.getBoundaries())

    @drawRectangle(shape)
    @drawLabel(label)

  #
  # @param type String (inclusive|exclusive_data|parallel|complex) - inclusive => O, exclusive_data => X, parallel => +, complex => *
  # @param position Object(top, left, width, height)
  # @param text String
  #
  drawGateway: (type, position, text) ->
    font = @font.copy()

    switch type
      when 'inclusive'
        text = 'O'
        font.size = 16
      when 'exclusive_data'
        text = 'X'
        font.size = 15
      when 'parallel'
        text = '+'
        font.size = 24
      when 'complex'
        text = '*'
        font.size = 30

    shape = new Diagram.Shape(position, 'gateway')
    label = new Diagram.Label(text, font)
    label.setMeasurer(@measurer)
    label.placeInside(shape.getBoundaries())

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