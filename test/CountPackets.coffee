test = require "noflo-test"

test.component("packets/CountPackets").
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
  discuss("given some IPs in groups").
    send.connect("in").
      send.beginGroup("in").
        send.data("in", "a").
        send.data("in", "b").
      send.endGroup("in").
      send.beginGroup("in").
        send.data("in", "c").
      send.endGroup("in").
      send.data("in", "d").
    send.disconnect("in").
  discuss("returns the number of IPs, for *EACH* group level").
    receive.beginGroup("out").
      receive.data("out", "a").
      receive.data("out", "b").
      receive.data("count", 2).
    receive.endGroup("out").
    receive.beginGroup("out").
      receive.data("out", "c").
      receive.data("count", 1).
    receive.endGroup("out").
    receive.data("out", "d").
    receive.data("count", 1).

export module
