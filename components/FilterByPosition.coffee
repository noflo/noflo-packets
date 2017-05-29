noflo = require("noflo")
_ = require("underscore")

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Filter packets based on their positions'
  c.icon = 'filter'
  c.inPorts.add 'in',
    datatype: 'all'
  c.inPorts.add 'filter',
    datatype: 'boolean'
  c.outPorts.add 'out',
    datatype: 'all'

  c.filters = []
  c.tearDown = (callback) ->
    c.filters = []
    do callback

  c.forwardBrackets = {}
  c.process (input, output) ->
    if input.hasData 'filter'
      filter = input.getData 'filter'
      c.filters.push filter
      output.done()
    return unless input.hasStream 'in'
    packets = input.getStream 'in'
    position = 0
    for ip in packets
      if ip.type is 'openBracket'
        position = 0
        output.send
          out: ip
        continue
      if ip.type is 'closeBracket'
        position = 0
        output.send
          out: ip
        continue
      unless c.filters[position]
        # Data packet filtered out
        position++
        continue
      output.send
        out: ip
      position++
      continue
    output.done()
