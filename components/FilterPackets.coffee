noflo = require("noflo")
_ = require("underscore")

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Filter packets matching some RegExp strings"
  c.icon = 'filter'
  c.inPorts.add 'in',
    datatype: 'string'
  c.inPorts.add 'regexp',
    datatype: 'string'
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'missed',
    datatype: 'string'
  c.outPorts.add 'passthru',
    datatype: 'string'

  c.forwardBrackets =
    in: ['out', 'missed', 'passthru']

  c.regexps = []
  c.tearDown = (callback) ->
    c.regexps = []

  c.process (input, output) ->
    if input.hasData 'regexp'
      reg = input.getData 'regexp'
      if typeof reg is 'string'
        reg = new RegExp reg
      c.regexps.push reg
      output.done()
      return

    return unless input.hasData 'in'
    data = input.getData 'in'
    if _.any c.regexps, ((regexp) -> data.match regexp)
      output.sendDone
        out: data
        passthru: data
      return
    output.sendDone
      missed: data
      passthru: data
