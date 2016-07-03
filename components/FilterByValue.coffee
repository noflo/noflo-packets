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

  #
  #  with autoordering, output is:
  # ['lower 0', 'lower 0.5', 'equal 1', 'higher 2', 'higher 1.5' ]
  #
  # with autoordering, output is:
  # [ 'lower 0', 'equal 1', 'higher 2', 'higher 1.5', 'lower 0.5' ]
  #
  # this is only because we are using output.send, but if we use direct port
  # access such as `output.ports.lower.send` instead of
  # `output.send lower:` autoOrdering does not need to be false
  #
  c.autoOrdering = false

  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'
    data = input.getStream('in').filter (ip) -> ip.type is 'data'
    filterValue = (input.getStream('filtervalue').map (ip) -> ip.data)[0]

    for packet in data
      if packet.data < filterValue
        output.send lower: packet.data
      else if packet.data > filterValue
        output.send higher: packet.data
      else if packet.data is filterValue
        output.send equal: packet.data

    output.done()
