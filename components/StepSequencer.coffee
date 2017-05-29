noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'A timestamp-value pattern sequencer'
  c.icon = 'bar-chart'
  c.inPorts.add 'pattern',
    datatype: 'string'
    description: 'Comma separated timestamp-value pairs. ' +
                 'Timestamps are in ms.'
  c.outPorts.add 'value',
    datatype: 'string'
    description: 'Current value'
  c.forwardBrackets = {}

  c.timers = {}
  c.tearDown = (callback) ->
    for scope, context of c.timers
      clearTimeout context.timeout if context.timeout
      context.deactivate()
    c.timers = {}

  c.process (input, output, context) ->
    return unless input.hasData 'pattern'

    if c.timers[input.scope]
      if c.timers[input.scope].timeout
        clearTimeout c.timers[input.scope].timeout
      c.timers[input.scope].deactivate()

    pattern = input.getData 'pattern'
    if typeof pattern is 'string'
      # TODO: trim whitespace?
      pattern = pattern.split ','
    return output.done() unless pattern.length > 1
    # TODO: validate ts to grow monolithically
    ix = 0
    last_val = 0
    last_ts = 0
    sendNext = ->
      last_ts = pattern[ix]
      last_val = pattern[ix + 1]
      output.send
        value: last_val
      ix += 2
      if ix < pattern.length
        context.timeout = setTimeout sendNext, pattern[ix] - last_ts
      else
        context.deactivate()
    context.timeout = setTimeout sendNext, pattern[ix]
    c.timers[input.scope] = context
