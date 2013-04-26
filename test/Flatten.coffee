test = require "noflo-test"

test.component("packets/Flatten").
  discuss("given some grouped IP structure").
    send.connect("in").
      send.beginGroup("in", "a").
        send.data("in", 1).
      send.endGroup("in", "a").
      send.beginGroup("in", "b").
        send.data("in", 2).
      send.endGroup("in", "b").
      send.beginGroup("in", "c").
        send.data("in", 3).
      send.endGroup("in", "c").
    send.disconnect("in").
  discuss("the structure is flattened").
    receive.data("out", 1).
    receive.data("out", 2).
    receive.data("out", 3).

  next().
  discuss("given some grouped IP structure").
    send.connect("in").
      send.beginGroup("in", "a").
        send.data("in", 1).
        send.beginGroup("in", "b").
          send.data("in", 2).
          send.beginGroup("in", "c").
            send.data("in", 3).
          send.endGroup("in", "c").
        send.endGroup("in", "b").
      send.endGroup("in", "a").
    send.disconnect("in").
  discuss("the structure is flattened").
    receive.beginGroup("out", "a").
      receive.data("out", 1).
    receive.endGroup("out", "a").
    receive.beginGroup("out", "b").
      receive.data("out", 2).
    receive.endGroup("out", "b").
    receive.beginGroup("out", "c").
      receive.data("out", 3).
    receive.endGroup("out", "c").

export module
