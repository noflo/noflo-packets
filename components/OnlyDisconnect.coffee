noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'the inverse of DoNotDisconnect'
    inPorts:
      in:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    output.send out: new noflo.IP 'closeBracket'
    output.done()
