noflo = require("noflo")
_ = require("underscore")

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Remove null"
  c.inPorts.add 'in',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'all'

  c.process (input, output) ->
    return unless input.hasData 'in'
    data = input.getData 'in'
    return output.done() unless data?
    return output.done() if data.length is 0
    return output.done() if _.isObject(data) and _.isEmpty(data)
    output.sendDone
      out: data
