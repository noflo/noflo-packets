noflo = require 'noflo'

# @runtime noflo-nodejs
exports.getComponent = ->
  c = new noflo.Component
    description: 'A timestamp-value pattern sequencer'
    icon: 'bar-chart'
    inPorts:
      pattern:
        datatype: 'string'
        description: 'Comma separated timestamp-value pairs. ' +
                     'Timestamps are in ms.'
    outPorts:
      value:
        datatype: 'string'
        description: 'Current value'

  c.sendNext = (config) ->
    config.last_ts = config.pattern[config.ix]
    config.last_val = config.pattern[config.ix + 1]
    c.outPorts.value.send config.last_val
    config.ix += 2
    if config.ix < config.pattern.length
      setTimeout ->
        c.sendNext config
      , config.pattern[config.ix]-config.last_ts
    else
      c.outPorts.value.disconnect()
      timer = null

  c.forwardBrackets =
    pattern: ['value']

  c.process (input, output) ->
    return unless input.has 'pattern'
    pattern = input.getData 'pattern'

    config =
      ix: 0
      pattern: []
      last_ts: 0
      last_val: 0

    # trim whitespace?
    # validate ts to grow monolithically
    return unless pattern.indexOf(',') isnt -1
    parts = pattern.split ','
    return unless parts.length > 0

    config.pattern = parts
    setTimeout ->
      c.sendNext config
    , config.pattern[config.ix]
