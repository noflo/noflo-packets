noflo = require("noflo")

# this is a generator
exports.getComponent = ->
  component = new noflo.Component

  component.description = "forwards everything but never disconnect"

  component.inPorts.add 'in', datatype: 'all', (event, payload) ->
    switch event
      when 'begingroup'
        component.outPorts.out.beginGroup(payload)

      when 'data'
        component.outPorts.out.send(payload)

      when 'endgroup'
        component.outPorts.out.endGroup()
  component.outPorts.add 'out', datatype: 'all'


  return component
