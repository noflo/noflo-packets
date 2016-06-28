noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Always send the specified packets with incoming packets.'
    inPorts:
      in:
        datatype: 'all'
        required: true
      with:
        datatype: 'all'
        required: true
    outPorts:
      out:
        datatype: 'all'

  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getStream 'in'
    sendWith = input.getStream 'with'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data

    for packet in stream
      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packet.data

      if packet.type is 'data'
        output.send out: packet.data

      if packet.type is 'closeBracket'
        output.send out: data for data in sendWith
        output.send out: new noflo.IP 'closeBracket', packet.data

    output.done()
