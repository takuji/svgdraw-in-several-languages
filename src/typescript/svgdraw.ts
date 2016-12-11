/// <reference path="../../typings/tsd.d.ts" />

class SVGDraw {
    width: number;
    height: number;
    el: string;
    line_color: string;
    line_width: number;
    background_color: string;
    zoom: number;
    event_listeners: any;
    lines: Line[];
    selection: d3.Selection<any>;
    svg: Element;
    status: State;
    image_url: string;
    pen: d3.svg.Line<[number, number]>;
    current_line: d3.Selection<any>;

    constructor(params) {
        const {width, height, el} = params
        this.width = width || 640
        this.height = height || 480
        if (!el) {
            throw Error('el is required')
        }
        this.line_color = '#000000'
        this.line_width = 1
        this.background_color = '#efefef'
        this.zoom = 1
        this.event_listeners = {}
        this.lines = []

        this.el = el
        this.selection = d3.select(el)
        this.svg = d3.select(el)[0][0] as Element;
        if (this.svg.nodeName != 'svg') {
            throw Error('el must specify a svg element.')
        }
        this.status = new WaitingState(this)
        this._initCanvas()
    }

    _initCanvas() {
        d3.select(this.el)
            .attr('width', `${this.width}px`)
            .attr('height', `${this.height}px`)
            .style('display', 'inline-block')
            .style('background-color', this.background_color)
            .on('mousedown', (e) => this.onMouseDown(e))
            .on('mousemove', (e) => this.onMouseMove(e))
            .on('mouseup', (e) => this.onMouseUp(e))
            .on('mouseleave', (e) => this.onMouseLeave(e))
    }

    getMousePosition() {
        return d3.mouse(this.svg)
    }

    onMouseDown(e) {
        this.status.onMouseDown(e)
    }

    onMouseUp(e) {
        this.status.onMouseUp(e)
    }

    onMouseMove(e) {
        this.status.onMouseMove(e)
    }

    onMouseLeave(e) {
        this.status.onMouseLeave(e)
    }

    setLineColor(line_color) {
        this.line_color = line_color
    }

    setLineWidth(line_width) {
        this.line_width = line_width
    }

    setBackgroundColor(background_color) {
        this.background_color = background_color
    }

    setImage(image_url) {
        this.image_url = image_url
        this.selection.insert('image', ':first-child')
            .attr('xlink:href', image_url)
            .attr('width', this.width)
            .attr('height', this.height)
    }

    clearImage() {
        this.image_url = null
        this.selection.selectAll('image').remove()
    }

    on(event, f) {
        if (!this.event_listeners[event]) {
            this.event_listeners[event] = []
        }
        this.event_listeners[event].push(f)
    }

    off(event, f) {
        const listeners = this.event_listeners[event]
        if (listeners) {
            const idx = listeners.indexOf(f)
            if (idx >= 0) {
                listeners.splice(idx, 1)
            }
        }
    }

    addLine(line) {
        this.lines.push(line)
        this.pen = d3.svg.line().interpolate('cardinal')
        const data = this.pen(line.points)
        this.current_line = this.selection.append('path')
            .attr('data-line_id', line.id)
            .attr('d', data)
            .attr('fill', 'transparent')
            .attr('stroke', line.color)
    }

    updateLine(line) {
        if (this.current_line && this.pen) {
            const data = this.pen(line.points)
            this.current_line.attr('d', data)
        }
    }

    closeLine(line) {
        if (this.current_line && this.pen) {
            const data = this.pen(line.points)
            this.current_line.attr('d', data)
        }
    }
}

class Line {
    color: string;
    width: number;
    points: [number, number][];

    constructor(params) {
        const { id } = params
        this.color = '#000000'
        this.width = 1
        this.points = []
        if (params.color) {
            this.color = params.color
        }
        if (params.width) {
            this.width = params.width
        }
    }
    addPoint(point) {
        this.points.push(point)
    }
}

class State {
    context: SVGDraw;

    constructor(context) {
        this.context = context
    }
    onMouseDown(e) { }
    onMouseUp(e) { }
    onMouseMove(e) { }
    onMouseLeave(e) { }
}

class WaitingState extends State {
    constructor(context) {
        super(context)
    }
    onMouseDown(e) {
        this.context.status = new DrawingState(this.context)
    }
    onMouseMove(e) {
        console.log("waiting")
    }
}

class DrawingState extends State {
    line_id_counter: number;
    line: Line;

    constructor(context) {
        super(context)
        this.line_id_counter = 0
        this.line = new Line({ id: ++this.line_id_counter })
        this.line.addPoint(context.getMousePosition())
        this.context.addLine(this.line)
    }
    onMouseMove(e) {
        this.line.addPoint(this.context.getMousePosition())
        this.context.updateLine(this.line);
    }
    onMouseUp(e) {
        console.log(this.line.points)
        this.context.closeLine(this.line)
        this.context.status = new WaitingState(this.context)
    }
    onMouseLeave(e) {
        this.context.closeLine(this.line)
        this.context.status = new WaitingState(this.context)
    }
}

export default SVGDraw;
