noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Filter packets based on their positions'
    inPorts:
      in:
        datatype: 'all'
      filter:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'

    count = 0
    stream = input.getStream 'in'
    filters = input.getStream 'filter'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data

    for packet in stream
      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packet.data

      if packet.type is 'data'
        if filters[count]
          output.send packet.data
        count++

      if packet.type is 'closeBracket'
        output.send out: new noflo.IP 'closeBracket', packet.data

    output.done()
