noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      in:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'

    stream = input.getStream 'in'
    data = stream.filter (ip) -> ip.type is 'data'

    return if data.length is 0

    for packet in stream
      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packet.data

    output.send data.pop()

    for packet in stream
      if packet.type is 'closeBracket'
        output.send out: new noflo.IP 'closeBracket', packet.data

    output.done()
