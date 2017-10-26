noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'outdent'
  c.description = 'Get scope of the IP packet'
  c.inPorts.add 'in',
    datatype: 'object'
  c.outPorts.add 'out',
    datatype: 'object'
  c.outPorts.add 'scope',
    datatype: 'string'
  c.process (input, output) ->
    return unless input.hasData 'in'
    data = input.getData 'in'
    output.sendDone
      scope: input.scope
      out: data
