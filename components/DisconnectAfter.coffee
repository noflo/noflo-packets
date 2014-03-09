noflo = require 'noflo'

class DisconnectAfter extends noflo.Component
  description: 'Pass a disconnect through after a certain number
  of packets has been passed'

  constructor: ->
    @count = 0
    @number = 1
    @allowDisconnect = false
    @inPorts =
      in: new noflo.Port 'all'
      packets: new noflo.Port 'int'
    @outPorts =
      out: new noflo.Port 'out'
      count: new noflo.Port 'int'

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'data', (data) =>
      @outPorts.out.send data
      @count++
      @allowDisconnect = true if @count >= @number
      return unless @outPorts.count.isAttached()
      @outPorts.count.beginGroup @number
      @outPorts.count.send @count
      @outPorts.count.endGroup()
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      return unless @allowDisconnect
      @outPorts.out.disconnect()
      @outPorts.count.disconnect() if @outPorts.count.isAttached()
      @count = 0
      @allowDisconnect = false
    
    @inPorts.packets.on 'data', (@number) =>
      @count = 0

exports.getComponent = -> new DisconnectAfter
