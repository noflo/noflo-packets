noflo = require 'noflo'

class Replace extends noflo.Component

  description: 'Replace incoming packets with something else if they match
  certain packets'

  constructor: ->
    @inPorts =
      in: new noflo.Port 'any'
      match: new noflo.Port 'any'
      replace: new noflo.Port 'any'
    @outPorts =
      out: new noflo.Port 'any'

    @inPorts.match.on 'connect', =>
      @matches = []
    @inPorts.match.on 'data', (match) =>
      @matches.push match

    @inPorts.replace.on 'connect', =>
      @replacements = []
    @inPorts.replace.on 'data', (replacement) =>
      @replacements.push replacement

    @inPorts.in.on 'begingroup', (group) =>
      @outPorts.out.beginGroup group
    @inPorts.in.on 'endgroup', =>
      @outPorts.out.endGroup()
    @inPorts.in.on 'disconnect', =>
      @outPorts.out.disconnect()

    @inPorts.in.on 'data', (data) =>
      index = @matches.indexOf data

      # Forward data as-is if no match; otherwise, send the replacement
      @outPorts.out.send if index > -1 then @replacements[index] else data

exports.getComponent = -> new Replace
