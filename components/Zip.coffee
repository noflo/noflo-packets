noflo = require("noflo")
_ = require("underscore")

exports.getComponent = ->
  c = new noflo.Component
  c.description = "zip through multiple IPs and output a series of zipped
  IPs just like how _.zip() works in Underscore.js"
  c.icon = 'file-archive-o'
  c.inPorts.add 'in',
    datatype: 'array'
  c.outPorts.add 'out',
    datatype: 'array'
  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    packets = input.getStream('in').filter((ip) ->
      return false unless ip.type is 'data'
      return false unless _.isArray ip.data
      true
    ).map (ip) -> ip.data
    if _.isEmpty packets
      output.sendDone
        out: []
      return
    output.sendDone
      out: _.zip.apply _, packets
