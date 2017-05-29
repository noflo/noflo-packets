noflo = require("noflo")

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Filter packets based on their value"
  c.icon = 'filter'
  c.inPorts.add 'in',
    datatype: 'number'
  c.inPorts.add 'filtervalue',
    datatype: 'number'
    control: true
    required: true
  c.outPorts.add 'lower',
    datatype: 'number'
  c.outPorts.add 'higher',
    datatype: 'number'
  c.outPorts.add 'equal',
    datatype: 'number'

  c.forwardBrackets =
    in: ['lower', 'higher', 'equal']

  c.process (input, output) ->
    return unless input.hasData 'in', 'filtervalue'
    filterValue = input.getData 'filtervalue'
    data = input.getData 'in'

    if data < filterValue
      output.sendDone
        lower: data
      return
    if data > filterValue
      output.sendDone
        higher: data
      return
    if data == filterValue
      output.sendDone
        equal: data
      return
    output.done()
