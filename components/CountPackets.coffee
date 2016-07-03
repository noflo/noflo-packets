noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'count number of data IPs'
    icon: 'sort-numeric-asc'
    inPorts:
      in:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'
      count:
        datatype: 'all'

  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'

    stream = input.getStream 'in'
    count = 0
    connect = true
    for packet in stream
      if connect
        connect = false
        continue

      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packet.data
        output.send count: new noflo.IP 'openBracket', packet.data
      if packet.type is 'data'
        count++
        output.send out: packet.data
      if packet.type is 'closeBracket'
        output.send count: count
        output.send count: new noflo.IP 'closeBracket', packet.data
        output.send out: new noflo.IP 'closeBracket', packet.data
        count = 0

    output.done()
