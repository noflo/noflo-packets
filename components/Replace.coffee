noflo = require 'noflo'

###
exports.getComponent = ->
  c = new noflo.Component
    description: 'Replace incoming packets with something else if they match
    certain packets'
    inPorts:
      in:
        datatype: 'all'
      replace:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getStream 'in'

    for packet in data
      if packet.type is 'openBracket'
        output.send out: new noflo.IP 'openBracket', packet.data

      if packet.type is 'data'
        c.outPorts.out.send packet.data

      if packet.type is 'closeBracket'
        output.send out: new noflo.IP 'closeBracket', packet.data



  c.inPorts.add 'in', datatype: 'any', (event, payload) ->
    switch event
      when 'begingroup'
        c.outPorts.out.beginGroup payload
      when 'endgroup'
        c.outPorts.out.endGroup()
      when 'disconnect'
        c.outPorts.out.disconnect()

      when 'data'
        index = c.matches.indexOf payload

        # Forward data as-is if no match; otherwise, send the replacement
        c.outPorts.out.send if index > -1 then c.replacements[index] else data
  c.inPorts.add 'match', datatype: 'any', (event, payload) ->
    switch event
      when 'connect'
        c.matches = []
      when 'data'
        c.matches.push payload

  c.inPorts.add 'replace', datatype: 'any', (event, payload) ->
    switch event
      when 'connect'
        c.replacements = []
      when 'data'
        c.replacements.push payload

  c.outPorts.add 'out', datatype: 'any'


  return c
###
