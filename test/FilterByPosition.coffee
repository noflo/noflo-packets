test = require "noflo-test"

test.component("packets/FilterByPosition").
  discuss("given some packets that are supposed to be booleans, indicating whether the corresponding packets are filtered").
    send.connect("filter").
    send.data("filter", true).
    send.data("filter", true).
    send.data("filter", false).
    send.data("filter", true).
    send.data("filter", false).
    send.data("filter", false).
    send.disconnect("filter").
  discuss("provide some data packets").
    send.connect("in").
    send.data("in", "passed").
    send.data("in", "passed").
    send.data("in", "dropped").
    send.data("in", "passed").
    send.data("in", "dropped").
    send.data("in", "dropped").
    send.disconnect("in").
  discuss("get only the passed ones").
    receive.data("out", "passed").
    receive.data("out", "passed").
    receive.data("out", "passed").

export module
