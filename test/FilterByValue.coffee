test = require "noflo-test"

test.component("packets/FilterByValue").
  discuss("given the value, indicating the outport of the filtered value").
    send.connect("filtervalue").
    send.data("filtervalue", 1).
    send.disconnect("filtervalue").
  discuss("provide some data packets").
    send.connect("in").
    send.data("in", 0).
    send.data("in", 1).
    send.data("in", 2).
    send.data("in", 1.5).
    send.data("in", 0.5).
    send.disconnect("in").
  discuss("get filtered ones").
    receive.data("lower", 0).
    receive.data("equal", 1).
    receive.data("higher", 2).
    receive.data("higher", 1.5).
    receive.data("lower", 0.5).

export module
