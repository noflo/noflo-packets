test = require "noflo-test"

test.component("packets/Range").
  discuss("given a starting position").
    send.data("start", 1).
  discuss("and a length").
    send.data("length", 2).
  discuss("provide some packets").
    send.connect("in").
      send.data("in", 1).
      send.data("in", 2).
      send.data("in", 3).
      send.data("in", 4).
      send.data("in", 5).
      send.data("in", 6).
    send.disconnect("in").
  discuss("take the specified packets").
    receive.data("out", 2).
    receive.data("out", 3).

  next().
  discuss("given a starting position and no length").
    send.data("start", 1).
  discuss("provide some packets").
    send.connect("in").
      send.data("in", 1).
      send.data("in", 2).
      send.data("in", 3).
      send.data("in", 4).
      send.data("in", 5).
      send.data("in", 6).
    send.disconnect("in").
  discuss("take the starting packets until the end").
    receive.data("out", 2).
    receive.data("out", 3).
    receive.data("out", 4).
    receive.data("out", 5).
    receive.data("out", 6).

  next().
  discuss("given a length but no starting position").
    send.data("length", 4).
  discuss("provide some packets").
    send.connect("in").
      send.data("in", 1).
      send.data("in", 2).
      send.data("in", 3).
      send.data("in", 4).
      send.data("in", 5).
      send.data("in", 6).
    send.disconnect("in").
  discuss("take the `length` number of packets from the first packet").
    receive.data("out", 1).
    receive.data("out", 2).
    receive.data("out", 3).
    receive.data("out", 4).

  next().
  discuss("given a starting and an ending position").
    send.data("start", 1).
    send.data("end", 4).
  discuss("provide some packets").
    send.connect("in").
      send.data("in", 1).
      send.data("in", 2).
      send.data("in", 3).
      send.data("in", 4).
      send.data("in", 5).
      send.data("in", 6).
    send.disconnect("in").
  discuss("take packets in between the positions, inclusive of start but exclusive of end").
    receive.data("out", 2).
    receive.data("out", 3).

  next().
  discuss("given just an ending position").
    send.data("end", 2).
  discuss("provide some packets").
    send.connect("in").
      send.data("in", 1).
      send.data("in", 2).
      send.data("in", 3).
      send.data("in", 4).
      send.data("in", 5).
      send.data("in", 6).
    send.disconnect("in").
  discuss("take the first packets until the specified one").
    receive.data("out", 1).

export module
