noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Surround each data packet by a bracket'
  c.icon = 'indent'
  c.inPorts.add 'in',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'all'
  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    packets = input.getStream 'in'
    datas = 0
    for ip in packets
      if ip.type is 'openBracket'
        datas = 0
        output.send
          out: ip
        continue
      if ip.type is 'closeBracket'
        output.send
          out: ip
        continue
      # Surround data packet with a new bracket telling position in stream
      output.send
        out: new noflo.IP 'openBracket', datas
      output.send
        out: ip
      output.send
        out: new noflo.IP 'closeBracket', datas
      datas++
    output.done()
