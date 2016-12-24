"use strict";

var d3 = require("d3");

exports.interpolate = function (mode) {
    return function(line) {
        return line.interpolate(mode);
    }
}

exports.setData = function(data) {
    return function(line) {
        return line(data);
    };
};
