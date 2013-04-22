noflo = require("noflo")

class CloseConnection extends noflo.Component

  description: "close HTTP connection"

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.in.on "data", (data) =>
      data?.end?()

exports.getComponent = -> new CloseConnection
