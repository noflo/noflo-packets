noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Send packets whose position upon receipt is even to the
    EVEN port, otherwise the ODD port.'
    inPorts:
      in:
        datatype: 'all'
    outPorts:
      odd:
        datatype: 'all'
      even:
        datatype: 'all'

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    count = 0
    stream = input.getStream 'in'
    data = stream.filter (ip) -> ip.type is 'data'

    for packet in data
      count++
      port = if count % 2 is 0 then "even" else "odd"
      c.outPorts[port].send(packet.data)

    c.outPorts.odd.disconnect()
    c.outPorts.even.disconnect()
