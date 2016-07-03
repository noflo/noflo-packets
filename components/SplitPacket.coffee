noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'splits each incoming packet into its own connection'
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
    openBrackets = stream.filter (ip) -> ip.type is 'openBracket'
    closeBrackets = stream.filter (ip) -> ip.type is 'closeBracket'

    if openBrackets[0]?.data is null
      openBrackets.shift()

    for packet, index in data
      openBracket = (openBrackets.shift())?.data or null
      output.send out: new noflo.IP 'openBracket', openBracket
      output.send out: packet.data
      output.send out: new noflo.IP 'closeBracket', openBracket

    output.done()
