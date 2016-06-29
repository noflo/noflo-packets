noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component
    description: 'zip through multiple IPs and output a series of zipped
    IPs just like how _.zip() works in Underscore.js'
    inPorts:
      in:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'

    stream = input.getStream 'in'
    data = stream
      .filter (ip) -> ip.type is 'data'
      .filter (ip) -> typeof ip.data is 'array' or typeof ip.data is 'object'
      .map (ip) -> ip.data

    if data.length is 0
      output.ports.out.send []
    else
      output.ports.out.send _.zip.apply _, data

    output.ports.out.disconnect()
    output.done()
