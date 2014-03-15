test = require "noflo-test"

test.component("packets/Counter").
  discuss("given some IPs").
    send.connect("in").
      send.data("in", "a").
      send.data("in", "b").
      send.data("in", "c").
      send.data("in", "d").
    send.disconnect("in").
  discuss("returns the number of IPs").
    receive.data("out", "a").
    receive.data("out", "b").
    receive.data("out", "c").
    receive.data("out", "d").
    receive.data("count", 4).

  next().
  discuss("given some IPs with immediate parameter").
    send.connect("immediate").
      send.data("immediate", true).
      send.disconnect("immediate").
    send.connect("in").
      send.data("in", "a").
      send.data("in", "b").
  discuss("returns the number of IPs").
    receive.data("out", "a").
    receive.data("count", 1).
    receive.data("out", "b").
    receive.data("count", 2).
    send.disconnect("in").

export module
