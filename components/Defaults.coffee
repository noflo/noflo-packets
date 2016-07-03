noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'if incoming is short of the length of the default
    packets, send the default packets.'
    inPorts:
      in:
        datatype: 'all'
      default:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.padPackets = (count, defaults) ->
    while count < defaults.length
      c.outPorts.out.send(defaults[count])
      count++

  # @TODO: fix
  c.forwardBrackets =
    default: 'out'

  c.process (input, output) ->
    return unless input.hasStream 'in'
    return unless input.hasStream 'default'

    stream = input.getStream 'in'
    defaults = input.getStream('default')
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> ip.data
    counts = [0]

    for packet in stream
      if packet.type is 'openBracket'
        counts.push(0)
        c.outPorts.out.beginGroup(packet.data)

      if packet.type is 'data'
        unless packet.data?
          packet.data = defaults[counts[counts.length - 1]]

        c.outPorts.out.send(packet.data)
        counts[counts.length - 1]++

      if packet.type is 'closeBracket'
        c.padPackets(counts[counts.length - 1], defaults)
        counts.pop()
        c.outPorts.out.endGroup()

    c.outPorts.out.disconnect()
    output.done()
