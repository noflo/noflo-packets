noflo = require 'noflo'

prepareMap = (orig) ->
  if typeof orig is 'object'
    return orig
  map = {}
  for mapPart in mapParts = orig.split ','
    mapEntry = mapPart.split ':'
    if mapEntry[0] and  mapEntry[1]
      map[mapEntry[0].trim()] = mapEntry[1].trim()
  return map

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'table'
  c.description = 'Replace packets through a map. Data that is not in the map is
  replace with the default.'
  c.inPorts.add 'data',
    datatype: 'all'
    description: 'Data to be used as a key.'
  c.inPorts.add 'map',
    datatype: 'all'
    description: 'A map with replacement values'
    control: true
    required: true
  c.inPorts.add 'def',
    datatype: 'all'
    description: 'A default value to return if the key is not in the map.
    If unset return the input.'
    control: true
  c.outPorts.add 'data',
    datatype: 'all'
    description: 'The content of map[data].'
  c.forwardBrackets =
    data: ['data']

  c.process (input, output) ->
    return unless input.hasData 'map', 'data'
    map = prepareMap input.getData 'map'
    data = input.getData 'data'
    if data of map
      output.sendDone
        data: map[data]
      return
    if input.hasData 'def'
      def = input.getData 'def'
      output.sendDone
        data: def
      return
    output.sendDone
      data: data
