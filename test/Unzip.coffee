test = require "noflo-test"

test.component("packets/Unzip").
  discuss("send some IPs").
    send.connect("in").
      send.data("in", 1).
      send.data("in", 2).
      send.data("in", 3).
      send.data("in", 4).
    send.disconnect("in").
  discuss("route them to either ODD or EVEN based on the packet position").
    receive.data("odd", 1).
    receive.data("even", 2).
    receive.data("odd", 3).
    receive.data("even", 4).

  next().
  discuss("send some IPs with groups").
    send.connect("in").
      send.beginGroup("in", "group").
        send.data("in", 1).
        send.data("in", 2).
        send.data("in", 3).
        send.data("in", 4).
      send.endGroup("in").
    send.disconnect("in").
  discuss("groups are ignored").
    receive.connect("odd").
      receive.data("odd", 1).
    receive.connect("even").
      receive.data("even", 2).
      receive.data("odd", 3).
      receive.data("even", 4).
    receive.disconnect("odd").
    receive.disconnect("even").

export module
