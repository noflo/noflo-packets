noflo = require("noflo")
_ = require("underscore")

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Flatten the IP structure but preserve all groups (i.e.
    all groups are at the top level)"
  c.icon = 'list'

  c.inPorts.add 'in',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'all'
  c.forwardBrackets = {}
  c.lastBracket = {}
  c.tearDown = (callback) ->
    c.lastBracket = {}
    do callback

  c.process (input, output) ->
    return unless input.has 'in'
    ip = input.get 'in'
    if ip.type is 'openBracket'
      if c.lastBracket[input.scope]
        output.send
          out: new noflo.IP 'closeBracket', c.lastBracket[input.scope].data
      output.send
        out: ip
      c.lastBracket[input.scope] = ip
      return output.done()
    if ip.type is 'closeBracket'
      return output.done() unless c.lastBracket[input.scope]
      output.send
        out: ip
      delete c.lastBracket[input.scope]
      return output.done()
    output.send
      out: ip
    return output.done()
