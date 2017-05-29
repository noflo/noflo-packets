noflo = require("noflo")
_ = require("underscore")

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'filter'
  c.description = "only forward a specified number of packets in a
  stream"
  c.inPorts.add 'in',
    datatype: 'all'
  c.inPorts.add 'start',
    datatype: 'int'
    control: true
  c.inPorts.add 'end',
    datatype: 'int'
    control: true
  c.inPorts.add 'length',
    datatype: 'int'
    control: true
  c.outPorts.add 'out',
    datatype: 'all'
  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'
    packets = input.getStream 'in'
    start = -Infinity
    if input.hasData 'start'
      start = parseInt input.getData 'start'
    end = +Infinity
    if input.hasData 'end'
      end = parseInt input.getData 'end'
    length = +Infinity
    if input.hasData 'length'
      length = parseInt input.getData 'length'
    sent = 0
    total = 0
    for ip in packets
      if ip.type in ['openBracket', 'closeBracket']
        sent = 0
        total = 0
        output.send
          out: ip
        continue
      total++
      if total > start and total < end and sent < length
        output.send
          out: ip
        sent++
      continue
    output.done()
