owl = require("owl-deepcopy")
noflo = require("noflo")
_ = require("underscore")

class SplitPacket extends noflo.Component

  description: "splits each incoming packet into its own connection"

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.in.on "data", (data) =>
      groups = @inPorts.in.getGroups()
      buffer = @inPorts.in.getBuffer()

      @outPorts.out.setBuffer(buffer)
      @outPorts.out.disconnect()

      # Get rid of the inserted data IP
      buf = buffer
      for group in groups
        buf = buf[group]
      delete buf["__DATA__"]

      # Reset buffer
      @inPorts.in.setBuffer(buffer)

    @inPorts.in.on "endgroup", (group) =>
      # Remove group if it's empty
      groups = @inPorts.in.getGroups()
      buffer = @inPorts.in.getBuffer()

      for group in groups
        buffer = buffer[group]
      if _.isEmpty(buffer[group])
        delete buffer[group]

exports.getComponent = -> new SplitPacket
