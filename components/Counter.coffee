noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'The count component receives input on a single input port,
    and sends the number of data packets received to the output port when
    the input disconnects'
    icon: 'sort-numeric-asc'
    inPorts:
      in:
        datatype: 'all'
        required: true
      immediate:
        datatype: 'boolean'
        control: true
        default: false
    outPorts:
      out:
        datatype: 'all'
      count:
        datatype: 'number'

  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getStream 'in'

    immediate = input.getData 'immediate'
    count = 0

    for packet in stream
      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packet.data
      if packet.type is 'data'
        count++
        if immediate
          output.send count: count
        output.send out: packet.data
      if packet.type is 'closeBracket'
        output.send out: new noflo.IP 'closeBracket', packet.data

    unless immediate
      output.send count: count

    output.done()
