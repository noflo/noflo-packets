noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Filter packets with regular expression'
  c.icon = 'filter'
  c.inPorts.add 'in',
    datatype: 'string'
  c.inPorts.add 'regexp',
    datatype: 'string'
    control: true
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'missed',
    datatype: 'string'

  c.forwardBrackets =
    in: ['out', 'missed']

  c.process (input, output) ->
    return unless input.hasData 'in'
    data = input.getData 'in'
    unless input.hasData 'regexp'
      # No regexp provided, just send data
      output.sendDone
        out: data
      return
    regexp = input.getData 'regexp'
    if typeof regexp is 'string'
      regexp = new RegExp regexp
    if regexp.exec data
      output.sendDone
        out: data
      return
    output.sendDone
      missed: data
