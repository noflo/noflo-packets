test = require "noflo-test"

test.component("packets/Compact").
  discuss("given some packets").
    send.data("in", []).
    send.data("in", 1).
    send.data("in", "").
    send.data("in", 2).
    send.data("in", null).
    send.data("in", false).
    send.data("in", {}).
    send.disconnect("in").
  discuss("get a clean version of that").
    receive.data("out", 1).
    receive.data("out", 2).
    receive.data("out", false).

export module
