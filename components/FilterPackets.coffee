noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Filter packets matching
    some RegExp strings'
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
      passthru:
        datatype: 'all'

  c.forwardBrackets = {}

  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getStream 'in'
    data = stream.filter (ip) -> ip.type is 'data'
    regexps = input.getStream 'regexp'
      .filter (ip) -> ip.type is 'data'
      .map (ip) -> new RegExp ip.data

    for packet in data
      if _.any regexps, ((regexp) -> packet.data.match regexp)
        c.outPorts.out.send packet.data
      else
        c.outPorts.missed.send packet.data
      c.outPorts.passthru.send packet.data

    c.outPorts.out.disconnect()
    c.outPorts.missed.disconnect()
    c.outPorts.passthru.disconnect()
    output.done()
