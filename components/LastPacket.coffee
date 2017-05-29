noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Send only the last packet of a stream'
  c.icon = 'caret-square-o-down'
  c.inPorts.add 'in',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'all'
  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    packets = input.getStream 'in'
    datas = packets.filter (ip) -> ip.type is 'data'
    output.sendDone
      out: datas.pop()
