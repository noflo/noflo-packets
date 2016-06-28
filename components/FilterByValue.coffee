noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Filter packets based on their value'
    inPorts:
      in:
        datatype: 'all'
      filtervalue:
        datatype: 'all'
        control: true
    outPorts:
      out:
        datatype: 'all'
      lower:
        datatype: 'all'
      higher:
        datatype: 'all'
      equal:
        datatype: 'all'

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    data = input.getStream('in').filter (ip) -> ip.type is 'data'
    filterValue = (input.getStream('filtervalue').map (ip) -> ip.data)[0]

    for packet in data
      if packet.data < filterValue
        #output.send lower: packet.data
        output.ports.lower.send packet.data
      else if packet.data > filterValue
        #output.send higher: packet.data
        output.ports.higher.send packet.data
      else if packet.data is filterValue
        #output.send equal: packet.data
        output.ports.equal.send packet.data

    output.done()
