noflo = require 'noflo'

class Map extends noflo.Component
  description: 'Replace packets through a map. Data that is not in the map is
  replace with the default.'

  constructor: ->
    @map = {}
    @def = null
    
    @inPorts = new noflo.InPorts
      data:
        datatype: 'all'
        description: 'Data to be used as a key.'
      map:
        datatype: 'all'
        description: 'A map with replacement values'
      def:
        datatype: 'all'
        description: 'A default value to return if the key is not in the map.
        If unset return the input.'

    @outPorts = new noflo.OutPorts
      data:
        datatype: 'all'
        description: 'The content of map[data].'

    @inPorts.data.on 'data', (data) =>
      if data of @map
        @outPorts.data.send @map[data]
      else
        if @def
          @outPorts.data.send @def
        else
          @outPorts.data.send data
  
    @inPorts.data.on 'disconnect', =>
      @outPorts.data.disconnect()

    @inPorts.map.on 'data', (map) =>
      if typeof map is 'object'
        @map = map
        return
      for mapPart in mapParts = map.split ','
        mapEntry = mapPart.split ':'
        if mapEntry[0] and  mapEntry[1]
          @map[mapEntry[0].trim()] = mapEntry[1].trim()

    @inPorts.def.on 'data', (def) =>
      @def = def


exports.getComponent = -> new Map()

