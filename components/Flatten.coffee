noflo = require 'noflo'
_ = require 'underscore'

exports.getComponent = ->
  c = new noflo.Component
    description: 'Flatten the IP structure but preserve all groups (i.e.
    all groups are at the top level)'
    inPorts:
      in:
        datatype: 'all'
    outPorts:
      out:
        datatype: 'all'

  c.locate = (groups, cache) ->
    _.reduce groups, ((loc, group) -> loc[group]), cache

  c.flatten = (node) ->
    groups = c.getNonArrayKeys node

    if groups.length is 0
      packets: node
      nodes: {}

    else
      subnodes = {}

      for group in groups
        { packets, nodes } = c.flatten node[group]
        delete node[group]
        subnodes[group] = packets
        _.extend subnodes, nodes

      packets: node
      nodes: subnodes

  c.getNonArrayKeys = (node) ->
    _.compact _.filter _.keys(node), (key) -> isNaN parseInt key

  c.flush = (node) ->
    console.log node

    for packet in node
      c.outPorts.out.send packet

    for group in c.getNonArrayKeys node
      c.outPorts.out.beginGroup group
      c.flush node[group]
      c.outPorts.out.endGroup()

  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getStream 'in'

    groups = []
    cache = []

    connect = true
    for packet in stream
      if connect
        connect = false
        continue

      if packet.type is 'openBracket'
        loc = c.locate groups, cache
        loc[packet.data] = []
        groups.push packet.data

      if packet.type is 'data'
        loc = c.locate groups, cache
        loc.push packet.data

      if packet.type is 'closeBracket'
        groups.pop()

    { packets, nodes } = c.flatten cache
    c.flush _.extend packets, nodes

    c.outPorts.out.disconnect()
    output.done()
