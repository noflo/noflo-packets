noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Replace incoming packets with something else if they match
    certain packets'
    inPorts:
      in:
        datatype: 'all'
      replace:
        datatype: 'all'
      match:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getDataStream 'in'
    matches = input.getDataStream 'match'
    replacements = input.getDataStream 'replace'

    for data in stream
      index = matches.indexOf data
      # Forward data as-is if no match; otherwise, send the replacement
      output.ports.out.send if index > -1 then replacements[index] else data
