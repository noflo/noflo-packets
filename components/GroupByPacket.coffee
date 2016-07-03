noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      in:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.process (input, output) ->
    packets = 0
    stream = input.getStream 'in'

    for packet in stream
      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packets++

      if packet.type is 'data'
        output.send out: packet.data
        packets++

      if packet.type is 'closeBracket'
        output.send out: new noflo.IP 'closeBracket', packet.data

    output.done()
