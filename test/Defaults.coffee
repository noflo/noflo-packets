test = require "noflo-test"

test.component("packets/Defaults").
  discuss("set some defaults").
    send.connect("default").
      send.data("default", "a").
      send.data("default", "b").
      send.data("default", "c").
      send.data("default", "d").
    send.disconnect("default").
  discuss("send something in").
    send.connect("in").
      send.data("in", "x").
      send.data("in", null).
    send.disconnect("in").
  discuss("get the defaults filled in in place of missing values").
    receive.data("out", "x").
    receive.data("out", "b").
    receive.data("out", "c").
    receive.data("out", "d").

  next().
  discuss("work with groups too").
    send.connect("default").
      send.data("default", "a").
      send.data("default", "b").
      send.data("default", "c").
      send.data("default", "d").
    send.disconnect("default").
  discuss("send something in").
    send.connect("in").
      send.beginGroup("in", "group").
        send.data("in", "x").
      send.endGroup("in").
      send.data("in", "y").
    send.disconnect("in").
  discuss("get the defaults filled in, for *EACH* group level").
    receive.beginGroup("out", "group").
      receive.data("out", "x").
      receive.data("out", "b").
      receive.data("out", "c").
      receive.data("out", "d").
    receive.endGroup("out").
    receive.data("out", "y").
    receive.data("out", "b").
    receive.data("out", "c").
    receive.data("out", "d").

export module
