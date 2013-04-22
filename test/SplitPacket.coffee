test = require "noflo-test"

test.component("packets/SplitPacket").
  discuss("give it some IPs").
    send.connect("in").
      send.data("in", "a").
      send.data("in", "b").
    send.disconnect("in").
  discuss("each IP becomes its own connection").
    receive.connect("out").
      receive.data("out", "a").
    receive.disconnect("out").
    receive.connect("out").
      receive.data("out", "b").
    receive.disconnect("out").

  next().
  discuss("given some IPs in groups").
    send.connect("in").
      send.beginGroup("in", "x").
        send.data("in", "a").
      send.endGroup("in").
      send.beginGroup("in", "y").
        send.data("in", "b").
      send.endGroup("in").
    send.disconnect("in").
  discuss("only groups enclosing a particular IP are forwarded").
    receive.connect("out").
      receive.beginGroup("out", "x").
        receive.data("out", "a").
      receive.endGroup("out").
    receive.disconnect("out").
    receive.connect("out").
      receive.beginGroup("out", "y").
        receive.data("out", "b").
      receive.endGroup("out").
    receive.disconnect("out").
 
export module
