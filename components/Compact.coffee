noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Remove null'
    inPorts:
      in:
        datatype: 'all'
        data: true
    outPorts:
      out:
        datatype: 'all'

  c.process (input, output) ->
    return unless input.hasDataStream 'in'
    stream = input.getDataStream 'in'

    for data in stream
      continue unless data?
      continue if data.length is 0
      if typeof(data) is 'object' and Object.keys(data).length is 0
        continue

      output.ports.out.sendIP new noflo.IP('data', data), null, {}, null, false
      #output.sendIP 'out', data # cannot use false on autoconnect

    output.done()

    ###
    #
    # Without dataStream
    #
    ##
    return unless input.hasStream 'in'

    stream = input.getStream 'in'

    # deal with the silly connect
    #if stream[0].type is 'openBracket' and stream[1].type is 'openBracket'
    #  delete stream[0]

    openBracket = (stream.filter (ip) -> ip.type is 'openBracket')[0]
    closeBracket = (stream.filter (ip) -> ip.type is 'closeBracket')[0]

    output.send new noflo.IP 'openBracket', openBracket.data

    for packet in stream
      continue unless packet.type is 'data'

      console.log 'is data'
      continue unless packet.data?
      continue if packet.data.length is 0
      if typeof(packet.data) is 'object' and
      Object.keys(packet.data).length is 0
        console.log 'has no keys eh'
        continue

      output.send packet.data

    output.send new noflo.IP 'closeBracket', closeBracket.data

    output.done()
    ###
