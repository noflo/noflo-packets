noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      in:
        datatype: 'all'
        required: true
      regexp:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'
      missed:
        datatype: 'all'

  c.filterData = (data, regexps) ->
    match = false
    for expression in regexps
      regexp = new RegExp expression
      continue unless regexp.exec data
      match = true

    unless match
      c.outPorts.missed.send data
      return

    c.outPorts.out.send data

  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'

    stream = input.getStream 'in'
    data = stream.filter (ip) -> ip.type is 'data'
    regexps = input.getStream 'regexp'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> new RegExp ip.data

    for packet in stream
      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packet.data
        output.send missed: new noflo.IP 'openBracket', packet.data

      if packet.type is 'data'
        if regexps.length
          c.filterData packet.data, regexps
          continue
        output.send out: packet.data

      if packet.type is 'closeBracket'
        output.send out: new noflo.IP 'closeBracket', packet.data
        output.send missed: new noflo.IP 'closeBracket', packet.data

    output.done()
