noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'indent'
  c.description = 'Set the scope of the received packet into a property inside the payload'
  c.inPorts.add 'in',
    datatype: 'object'
    scoped: true
  c.inPorts.add 'property',
    datatype: 'string'
    control: true
    default: 'scope'
    scoped: false
  c.outPorts.add 'out',
    datatype: 'object'
    scoped: false
  c.process (input, output) ->
    return unless input.hasData 'in'
    return if input.attached('property').length and not input.hasData 'property'
    property = 'scope'
    if input.hasData 'property'
      property = input.getData 'property'
    data = input.getData 'in'
    data[property] = input.scope
    output.sendDone
      out: new noflo.IP 'data', data
