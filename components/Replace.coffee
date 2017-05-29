noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'clipboard'
  c.description = 'Replace incoming packets with something else if they match
  certain packets'
  c.inPorts.add 'in',
    datatype: 'all'
  c.inPorts.add 'match',
    datatype: 'all'
  c.inPorts.add 'replace',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'all'
  c.matches = {}
  c.replacements = {}
  c.tearDown = (callback) ->
    c.matches = {}
    c.replacements = {}
  c.process (input, output) ->
    if input.hasData 'match'
      c.matches[input.scope] = [] unless c.matches[input.scope]
      c.matches[input.scope].push input.getData 'match'
      return output.done()
    if input.hasData 'replace'
      c.replacements[input.scope] = [] unless c.replacements[input.scope]
      c.replacements[input.scope].push input.getData 'replace'
      return output.done()
    return unless input.hasData 'in'
    data = input.getData 'in'
    if c.matches[input.scope] and c.replacements[input.scope]
      index = c.matches[input.scope].indexOf data
      unless index is -1
        # Send replacement
        data = c.replacements[input.scope][index]
    output.sendDone
      out: data
