/// <reference path="../../typings/tsd.d.ts" />
"use strict";
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
};
var SVGDraw = (function () {
    function SVGDraw(params) {
        var width = params.width, height = params.height, el = params.el;
        this.width = width || 640;
        this.height = height || 480;
        if (!el) {
            throw Error('el is required');
        }
        this.line_color = '#000000';
        this.line_width = 1;
        this.background_color = '#efefef';
        this.zoom = 1;
        this.event_listeners = {};
        this.lines = [];
        this.el = el;
        this.selection = d3.select(el);
        this.svg = d3.select(el)[0][0];
        if (this.svg.nodeName != 'svg') {
            throw Error('el must specify a svg element.');
        }
        this.status = new WaitingState(this);
        this._initCanvas();
    }
    SVGDraw.prototype._initCanvas = function () {
        var _this = this;
        d3.select(this.el)
            .attr('width', this.width + "px")
            .attr('height', this.height + "px")
            .style('display', 'inline-block')
            .style('background-color', this.background_color)
            .on('mousedown', function (e) { return _this.onMouseDown(e); })
            .on('mousemove', function (e) { return _this.onMouseMove(e); })
            .on('mouseup', function (e) { return _this.onMouseUp(e); })
            .on('mouseleave', function (e) { return _this.onMouseLeave(e); });
    };
    SVGDraw.prototype.getMousePosition = function () {
        return d3.mouse(this.svg);
    };
    SVGDraw.prototype.onMouseDown = function (e) {
        this.status.onMouseDown(e);
    };
    SVGDraw.prototype.onMouseUp = function (e) {
        this.status.onMouseUp(e);
    };
    SVGDraw.prototype.onMouseMove = function (e) {
        this.status.onMouseMove(e);
    };
    SVGDraw.prototype.onMouseLeave = function (e) {
        this.status.onMouseLeave(e);
    };
    SVGDraw.prototype.setLineColor = function (line_color) {
        this.line_color = line_color;
    };
    SVGDraw.prototype.setLineWidth = function (line_width) {
        this.line_width = line_width;
    };
    SVGDraw.prototype.setBackgroundColor = function (background_color) {
        this.background_color = background_color;
    };
    SVGDraw.prototype.setImage = function (image_url) {
        this.image_url = image_url;
        this.selection.insert('image', ':first-child')
            .attr('xlink:href', image_url)
            .attr('width', this.width)
            .attr('height', this.height);
    };
    SVGDraw.prototype.clearImage = function () {
        this.image_url = null;
        this.selection.selectAll('image').remove();
    };
    SVGDraw.prototype.on = function (event, f) {
        if (!this.event_listeners[event]) {
            this.event_listeners[event] = [];
        }
        this.event_listeners[event].push(f);
    };
    SVGDraw.prototype.off = function (event, f) {
        var listeners = this.event_listeners[event];
        if (listeners) {
            var idx = listeners.indexOf(f);
            if (idx >= 0) {
                listeners.splice(idx, 1);
            }
        }
    };
    SVGDraw.prototype.addLine = function (line) {
        this.lines.push(line);
        this.pen = d3.svg.line().interpolate('cardinal');
        var data = this.pen(line.points);
        this.current_line = this.selection.append('path')
            .attr('data-line_id', line.id)
            .attr('d', data)
            .attr('fill', 'transparent')
            .attr('stroke', line.color);
    };
    SVGDraw.prototype.updateLine = function (line) {
        if (this.current_line && this.pen) {
            var data = this.pen(line.points);
            this.current_line.attr('d', data);
        }
    };
    SVGDraw.prototype.closeLine = function (line) {
        if (this.current_line && this.pen) {
            var data = this.pen(line.points);
            this.current_line.attr('d', data);
        }
    };
    return SVGDraw;
}());
var Line = (function () {
    function Line(params) {
        var id = params.id;
        this.color = '#000000';
        this.width = 1;
        this.points = [];
        if (params.color) {
            this.color = params.color;
        }
        if (params.width) {
            this.width = params.width;
        }
    }
    Line.prototype.addPoint = function (point) {
        this.points.push(point);
    };
    return Line;
}());
var State = (function () {
    function State(context) {
        this.context = context;
    }
    State.prototype.onMouseDown = function (e) { };
    State.prototype.onMouseUp = function (e) { };
    State.prototype.onMouseMove = function (e) { };
    State.prototype.onMouseLeave = function (e) { };
    return State;
}());
var WaitingState = (function (_super) {
    __extends(WaitingState, _super);
    function WaitingState(context) {
        return _super.call(this, context) || this;
    }
    WaitingState.prototype.onMouseDown = function (e) {
        this.context.status = new DrawingState(this.context);
    };
    WaitingState.prototype.onMouseMove = function (e) {
        console.log("waiting");
    };
    return WaitingState;
}(State));
var DrawingState = (function (_super) {
    __extends(DrawingState, _super);
    function DrawingState(context) {
        var _this = _super.call(this, context) || this;
        _this.line_id_counter = 0;
        _this.line = new Line({ id: ++_this.line_id_counter });
        _this.line.addPoint(context.getMousePosition());
        _this.context.addLine(_this.line);
        return _this;
    }
    DrawingState.prototype.onMouseMove = function (e) {
        this.line.addPoint(this.context.getMousePosition());
        this.context.updateLine(this.line);
    };
    DrawingState.prototype.onMouseUp = function (e) {
        console.log(this.line.points);
        this.context.closeLine(this.line);
        this.context.status = new WaitingState(this.context);
    };
    DrawingState.prototype.onMouseLeave = function (e) {
        this.context.closeLine(this.line);
        this.context.status = new WaitingState(this.context);
    };
    return DrawingState;
}(State));
exports.__esModule = true;
exports["default"] = SVGDraw;
