noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'filter'
  c.description = 'Send only packets that are unique'
  c.inPorts.add 'in',
    datatype: 'all'
  c.inPorts.add 'clear',
    datatype: 'bang'
  c.outPorts.add 'out',
    datatype: 'all'
  c.outPorts.add 'duplicate',
    datatype: 'all'
  c.seen = {}
  c.tearDown = (callback) ->
    c.seen = {}
    do callback
  c.forwardBrackets =
    in: ['out', 'duplicate']
  c.process (input, output) ->
    if input.hasData 'clear'
      input.getData 'clear'
      c.seen = {}
      return output.done()
    return unless input.hasData 'in'
    data = input.getData 'in'
    c.seen[input.scope] = [] unless c.seen[input.scope]
    if c.seen[input.scope].indexOf(data) is -1
      # Unique
      output.send
        out: data
      c.seen[input.scope].push data
      return output.done()
    output.sendDone
      duplicate: data
