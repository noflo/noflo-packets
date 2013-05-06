test = require "noflo-test"

test.component("packets/FilterPackets").
  discuss("given some RegExp strings").
    send.connect("regexp").
    send.data("regexp", "^ab").
    send.data("regexp", "c$").
    send.disconnect("regexp").
  discuss("provide some data packets").
    send.connect("in").
    send.data("in", "abe").
    send.data("in", "afg").
    send.data("in", "dfg").
    send.data("in", "dc").
    send.disconnect("in").
  discuss("anything that matches is directed to 'OUT', otherwise 'MISSED', but a copy of everything is forwarded to 'PASSTHRU'").
    receive.data("out", "abe").
    receive.data("passthru", "abe").
    receive.data("missed", "afg").
    receive.data("passthru", "afg").
    receive.data("missed", "dfg").
    receive.data("passthru", "dfg").
    receive.data("out", "dc").
    receive.data("passthru", "dc").

export module
