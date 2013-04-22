noflo = require("noflo")

class DefaultPackets extends noflo.Component

  description: "If incoming is short of the length of the default packets, send the default packets."

  constructor: ->
    @inPorts =
      in: new noflo.Port
      default: new noflo.Port
    @outPorts =
      out: new noflo.ArrayPort

    @inPorts.default.on "data", (data) =>
      if @default?
        @default.push(data)
      else
        @default = [data]

    @inPorts.in.on "connect", =>
      @count = 0

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      if data?
        @outPorts.out.send(data)
      else if @default?
        @outPorts.out.send(@default[@count])

      @count++

    @inPorts.in.on "endgroup", (group) =>
      @padPackets()
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @padPackets()
      @outPorts.out.disconnect()

  padPackets: ->
    if @default?
      while @count < @default.length
        @outPorts.out.send(@default[@count])
        @count++
 
exports.getComponent = -> new DefaultPackets
