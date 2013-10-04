noflo = require 'noflo'

class UniquePacket extends noflo.Component
  constructor: ->
    @seen = []

    @inPorts =
      in: new noflo.Port 'all'
      clear: new noflo.Port 'bang'
    @outPorts =
      out: new noflo.Port 'all'
      duplicate: new noflo.Port 'all'

    @inPorts.in.on 'data', (data) =>
      unless @unique data
        return unless @outPorts.duplicate.isAttached()
        @outPorts.duplicate.send data
        return
      @outPorts.out.send data
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

    @inPorts.clear.on 'data', =>
      @seen = []

  unique: (packet) ->
    return false unless @seen.indexOf(packet) is -1
    @seen.push packet
    return true

exports.getComponent = -> new UniquePacket
