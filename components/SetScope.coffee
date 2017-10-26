noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'indent'
  c.description = 'Set scope for the IP packet'
  c.inPorts.add 'in',
    datatype: 'object'
  c.inPorts.add 'scope',
    datatype: 'string'
    control: true
  c.outPorts.add 'out',
    datatype: 'object'
    scoped: true
  c.process (input, output) ->
    return unless input.hasData 'in', 'scope'
    [data, scope] = input.getData 'in', 'scope'
    output.sendDone
      out: new noflo.IP 'data', data,
        scope: scope
