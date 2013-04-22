noflo = require("noflo")
inherit = require("multiple-inheritance")

class MergeConnections extends noflo.SessionComponent

  description: "merges a number of incoming connections into one"

  constructor: ->
    @count = 0
    @threshold = 0

    @inPorts =
      in: new noflo.ArrayPort
      count: new noflo.Port
    @outPorts =
      out: new noflo.Port

    super

    @inPorts.count.on "data", (@threshold) =>

    @inPorts.in.on "disconnect", =>
      @count++

      # Record the current connection
      buffers = @getSessionData(unless @hasSession() then "__DEFAULT__") or []
      buffers.push(@inPorts.in.getBuffer())

      # Flush if the count is met
      if @count >= @threshold
        @outPorts.out.setBuffer(@compress(buffers))
        @outPorts.out.disconnect()
        @count = 0
        @closeSession()
      else
        @setSessionData(buffers)

  compress: (data) ->
    if data.length > 1
      inherit.merge(data[0], @compress(_.rest(data, 1)))
    else
      data[0]

exports.getComponent = -> new MergeConnections
