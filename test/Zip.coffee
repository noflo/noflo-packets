test = require "noflo-test"

test.component("packets/Zip").
  discuss("given some arrays").
    send.data("in", [1, 2, 3]).
    send.data("in", ["a", "b", "c"]).
    send.disconnect("in").
  discuss("they're then zipped").
    receive.data("out", [[1, "a"], [2, "b"], [3, "c"]]).
    receive.disconnect("out").

  next().
  discuss("groups are ignored and dropped").
    send.beginGroup("in", "groupA").
      send.data("in", [1, 2, 3]).
    send.endGroup("in").
    send.beginGroup("in", "groupB").
      send.data("in", ["a", "b", "c"]).
    send.endGroup("in").
    send.disconnect("in").
  discuss("they're then zipped").
    receive.data("out", [[1, "a"], [2, "b"], [3, "c"]]).
    receive.disconnect("out").

  next().
  discuss("without any array data packets").
    send.data("in", 1).
    send.data("in", "a").
    send.disconnect("in").
  discuss("nothing happens").
    receive.data("out", []).
    receive.disconnect("out").

export module
