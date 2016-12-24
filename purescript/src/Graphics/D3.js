"use strict";

var d3 = require("d3");

exports.select = function(el) {
    return d3.select(el);
};

exports.elemImpl = function(selection) {
    return selection[0][0];
}

exports.setAttr = function(name) {
    return function(value) {
        return function(selection) {
            return function() {
                return selection.attr(name, value);
            }
        };
    };
};

exports.setStyle = function(name) {
    return function(value) {
        return function(selection) {
            return function() {
                return selection.style(name, value);
            }
        };
    };
};

exports.on = function(name) {
    return function(handler) {
        return function(selection) {
            return function() {
                return selection.on(name, handler);
            }
        };
    };
};

exports.mouse = function(el) {
    return ds.mouse(el);
}

exports.append = function(tag) {
    return function(selection) {
        return selection.append(tag);
    };
};
