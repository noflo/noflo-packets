noflo = require 'noflo'

# @runtime noflo-nodejs
class StepSequencer extends noflo.Component
  description: 'A timestamp-value pattern sequencer'
  icon: 'bar-chart'

  constructor: ->
    @ix = 0
    @pattern = []
    @last_ts = 0
    @last_val = 0

    @inPorts = new noflo.InPorts
      pattern:
        datatype: 'string'
        description: 'Comma separated timestamp-value pairs. ' +
                     'Timestamps are in ms.'

    @outPorts = new noflo.OutPorts
      value:
        datatype: 'string'
        description: 'Current value'
        
    @inPorts.pattern.on 'data', (data) =>
      # trim whitespace?
      # validate ts to grow monolithically
      return unless data.indexOf(',') != -1
      parts = data.split ','
      return unless parts.length > 0

      #console.log "vv1/#{@constructor.name}: valid, len=#{parts.length}"
      @outPorts.value.connect()
      @pattern = parts
      @ix = 0
      @last_val = 0
      @last_ts = 0
      cb = @sendNext.bind @
      setTimeout cb, @pattern[@ix]

  sendNext: ->
    @last_ts = @pattern[@ix]
    @last_val = @pattern[@ix + 1]
    #console.log "vv1/#{@constructor.name}: send #{@last_val} at #{@last_ts}"
    @outPorts.value.send @last_val
    @ix += 2
    if @ix < @pattern.length
      cb = @sendNext.bind @
      setTimeout cb, @pattern[@ix]-@last_ts
    else
      @outPorts.value.disconnect()
      @timer = null
      #console.log "vv1/#{@constructor.name}: done"

exports.getComponent = -> new StepSequencer

