noflo = require("noflo")
_ = require("underscore")

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Count number of data IPs inside each stream'
  c.icon = 'sort-numeric-asc'
  c.inPorts.add 'in',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'all'
  c.outPorts.add 'count',
    datatype: 'int'
  c.counts = [0]
  c.tearDown = (callback) ->
    c.counts = [0]
    do callback

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.has 'in'
    ip = input.get 'in'
    if ip.type is 'openBracket'
      c.counts.push 0
      output.sendDone
        out: ip
        count: ip
      return
    if ip.type is 'closeBracket'
      count = _.last c.counts
      c.counts.pop()
      output.send
        count: count
      output.sendDone
        out: ip
        count: ip
      return
    # Data packet, add to count
    c.counts[c.counts.length - 1]++
    # Forward packet
    output.send
      out: ip

    if c.counts.length is 1
      # Non-bracketed IP, send count
      output.send
        count: _.last c.counts
      c.counts[c.counts.length - 1] = 0

    output.done()
