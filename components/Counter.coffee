noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'send a number of packets received in a stream'
  c.icon = 'sort-numeric-asc'

  c.count = 0
  c.brackets = []
  c.tearDown = (callback) ->
    c.count = 0
    c.brackets = []
    do callback

  c.inPorts.add 'in',
    datatype: 'all'
  c.inPorts.add 'immediate',
    datatype: 'boolean'
    control: true
    default: false
  c.inPorts.add 'reset',
    datatype: 'bang'
  c.outPorts.add 'count',
    datatype: 'int'
  c.outPorts.add 'out',
    datatype: 'all'

  c.forwardBrackets = {}

  c.process (input, output) ->
    if input.hasData 'reset'
      # When receiving bang on the reset, reset COUNT to zero
      input.getData 'reset'
      c.count = 0
      return output.done()

    return unless input.has 'in'

    ip = input.get 'in'
    if ip.type is 'openBracket'
      c.brackets.push ip.data
      return output.sendDone
        out: ip
    if ip.type is 'closeBracket'
      c.brackets.pop()
      output.send
        out: ip
      unless c.brackets.length
        # Send COUNT at end of stream
        output.send
          count: c.count
        c.count = 0
      return output.done()

    # When receiving data from IN port
    c.count++
    # Forward the data packet to OUT
    output.send
      out: ip

    immediate = false
    if input.hasData 'immediate'
      immediate = input.getData 'immediate'
    if immediate or c.brackets.length is 0
      output.send
        count: c.count
      c.count = 0 if c.brackets.length is 0
    output.done()
