noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      in:
        datatype: 'all'
      clear:
        datatype: 'bang'
    outPorts:
      out:
        datatype: 'all'
      duplicate:
        datatype: 'all'

  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'

    stream = input.getStream 'in'
    openBrackets = stream.filter (ip) -> ip.type is 'openBracket'
    closeBrackets = stream.filter (ip) -> ip.type is 'closeBracket'
    data = stream.filter (ip) -> ip.type is 'data'

    seen = []

    unique = (packet) ->
      return false unless seen.indexOf(packet) is -1
      seen.push packet
      return true


    for packet in data
      ###
      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packet.data
        output.send duplicate: new noflo.IP 'openBracket', packet.data
      ###

      if packet.type is 'data'
        unless unique packet.data
          c.outPorts.duplicate.send packet.data
          continue

        for openBracket in openBrackets
          output.send out: new noflo.IP 'openBracket', openBracket.data
        c.outPorts.out.send packet.data
        for closeBracket in closeBrackets
          output.send out: new noflo.IP 'closeBracket', closeBracket.data

      ###
      if packet.type is 'closeBracket'
        output.send out: new noflo.IP 'closeBracket', packet.data
        output.send duplicate: new noflo.IP 'closeBracket', packet.data
      ###

      # it was wrapping each packet in the bracket data
      #component.outPorts.out.send data

      c.outPorts.duplicate.disconnect()
      c.outPorts.out.disconnect()
      output.done()

