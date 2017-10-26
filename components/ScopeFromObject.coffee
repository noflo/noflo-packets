noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'outdent'
  c.description = 'Read the scope from received packet and set to IP scope'
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
    scoped: true
  c.process (input, output) ->
    return unless input.hasData 'in'
    return if input.attached('property').length and not input.hasData 'property'
    property = 'scope'
    if input.hasData 'property'
      property = input.getData 'property'
    data = input.getData 'in'
    scope = data[property]
    delete data[property]
    output.sendDone
      out: new noflo.IP 'data', data,
        scope: scope
