noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Replace packets through a map. Data that is not in the map is
    replace with the default.'
    inPorts:
      data:
        datatype: 'all'
        description: 'Data to be used as a key.'
      map:
        datatype: 'all'
        description: 'A map with replacement values'
        required: true
      default:
        datatype: 'all'
        description: 'A default value to return if the key is not in the map.
        If unset return the input.'
        control: true
    outPorts:
      data:
        datatype: 'all'
        description: 'The content of map[data].'
        required: false

  c.forwardBrackets =
    data: ['data']
    map: ['data']

  c.process (input, output) ->
    return unless input.hasStream 'data'
    data = input.getStream('data')[0].data
    map = input.getStream('map')[0].data
    def = input.getData 'default'

    unless typeof map is 'object'
      for mapPart in mapParts = map.split ','
        mapEntry = mapPart.split ':'
        if mapEntry[0] and  mapEntry[1]
          map[mapEntry[0].trim()] = mapEntry[1].trim()

    if data of map
      c.outPorts.data.send map[data]
    else
      if def
        c.outPorts.data.send def
      else
        c.outPorts.data.send data

    output.ports.data.disconnect()
    output.done()
