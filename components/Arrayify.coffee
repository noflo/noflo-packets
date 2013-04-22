_ = require("underscore")
noflo = require("noflo")

class Arrayify extends noflo.Component

  description: "merges incoming IPs into one array"

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      @outPorts.out.send(data)

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup(group)

    @inPorts.in.on "disconnect", =>
      @arrayify(@outPorts.out.getBuffer())
      @outPorts.out.disconnect()

  arrayify: (conn) ->
    arrayify = (level) ->
      for key, value of level
        if key is "__DATA__"
          # Arrayify only if it hasn't been arrayified yet
          if value.length > 1 or not _.isArray(value[0])
            level[key] = [value]
        else
          arrayify(value)

    arrayify(conn)

exports.getComponent = -> new Arrayify
