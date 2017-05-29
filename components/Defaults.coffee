noflo = require("noflo")
_ = require("underscore")

exports.getComponent = ->
  c = new noflo.Component
  c.description = "if incoming is short of the length of the default
  packets, send the default packets."
  c.inPorts.add 'in',
    datatype: 'all'
  c.inPorts.add 'default',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'all'

  c.defaults = []
  c.brackets = []
  c.tearDown = (callback) ->
    c.defaults = []
    c.brackets = []
    do callback

  c.forwardBrackets = {}
  c.process (input, output) ->
    if input.hasData 'default'
      def = input.getData 'default'
      c.defaults.push def
      output.done()
    return unless input.has 'in'
    ip = input.get 'in'
    if ip.type is 'openBracket'
      c.brackets.push []
      output.sendDone
        out: ip
      return
    if ip.type is 'closeBracket'
      packets = c.brackets.pop()
      defaulted = c.defaults.map (def, idx) ->
        if packets[idx]?
          return packets[idx]
        return def
      for def in defaulted
        output.send
          out: def
      output.sendDone
        out: ip
      return

    unless c.brackets.length
      # Unbracketed packet
      data = if ip.data? then ip.data else c.defaults[0]
      output.sendDone
        out: data
      return

    c.brackets[c.brackets.length - 1].push ip.data
    output.done()
