noflo = require("noflo")
_ = require("underscore")

class CountPackets extends noflo.Component

  description: "count number of data IPs"
  icon: 'sort-numeric-asc'

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port
      count: new noflo.Port

    @inPorts.in.on "connect", =>
      @counts = [0]
      count = _.last(@counts)

    @inPorts.in.on "begingroup", (group) =>
      @counts.push(0)
      @outPorts.out.beginGroup(group)
      @outPorts.count.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      @counts[@counts.length - 1]++
      @outPorts.out.send(data)

    @inPorts.in.on "endgroup", (group) =>
      count = _.last(@counts)
      @counts.pop()
      @outPorts.count.send(count)
      @outPorts.count.endGroup()
      @outPorts.count.disconnect()
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      count = _.last(@counts)
      @outPorts.count.send(count)
      @outPorts.count.disconnect()
      @outPorts.out.disconnect()

exports.getComponent = -> new CountPackets
