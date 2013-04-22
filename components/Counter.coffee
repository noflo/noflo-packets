noflo = require("noflo")

class Counter extends noflo.Component

  description: "count number of data IPs"

  constructor: ->
    @count = 0

    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port
      count: new noflo.Port

    @inPorts.in.on "connect", =>
      @count = 0

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      @count++
      @outPorts.out.send(data)

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup(group)

    @inPorts.in.on "disconnect", =>
      # Send count first, then regular output
      @outPorts.count.send(@count)
      @outPorts.count.disconnect()
      @outPorts.out.disconnect()

exports.getComponent = -> new Counter
