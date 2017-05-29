noflo = require("noflo")

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Always send the specified packets with incoming packets."
  c.inPorts.add 'in',
    datatype: 'all'
  c.inPorts.add 'with',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'all'
  c.with = {}
  c.tearDown = (callback) ->
    c.with = {}
    do callback
  c.forwardBrackets = {}
  c.process (input, output) ->
    if input.hasData 'with'
      c.with[input.scope] = [] unless c.with[input.scope]
      c.with[input.scope].push input.getData 'with'
      return output.done()
    return unless input.hasStream 'in'
    packets = input.getStream 'in'
    datas = packets.filter (ip) -> ip.type is 'data'
    for ip, idx in packets
      output.send
        out: ip
      continue unless ip is datas[datas.length - 1]
      continue unless c.with[input.scope]
      # Send 'withs' after last data IP
      for packet in c.with[input.scope]
        output.send
          out: packet
    output.done()
