noflo = require("noflo")

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Send packets whose position upon receipt is even to the
  EVEN port, otherwise the ODD port."
  c.icon = 'code-fork'
  c.inPorts.add 'in',
    datatype: 'all'
  c.outPorts.add 'odd',
    datatype: 'all'
  c.outPorts.add 'even',
    datatype: 'all'
  c.count = {}
  c.tearDown = (callback) ->
    c.count = {}
    do callback
  c.forwardBrackets =
    in: ['odd', 'even']
  c.process (input, output) ->
    return unless input.hasData 'in'
    data = input.getData 'in'
    c.count[input.scope] = 0 unless c.count[input.scope]
    c.count[input.scope]++
    if c.count[input.scope] % 2 is 0
      output.sendDone
        even: data
      return
    output.sendDone
      odd: data
