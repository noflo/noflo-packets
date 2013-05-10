test = require "noflo-test"

test.component("packets/SendWith").
  discuss("give some packets to always send with the incoming").
    send.connect("with").
    send.data("with", 4).
    send.data("with", 5).
    send.data("with", 6).
    send.disconnect("with").
  discuss("send some incoming").
    send.connect("in").
    send.data("in", 1).
    send.data("in", 2).
    send.data("in", 3).
    send.disconnect("in").
  discuss("get both incoming and the sent-with packets").
    receive.data("out", 1).
    receive.data("out", 2).
    receive.data("out", 3).
    receive.data("out", 4).
    receive.data("out", 5).
    receive.data("out", 6).

export module
