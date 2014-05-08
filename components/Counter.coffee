noflo = require 'noflo'

class Counter extends noflo.Component
  description: 'The count component receives input on a single input port,
    and sends the number of data packets received to the output port when
    the input disconnects'
  icon: 'sort-numeric-asc'

  constructor: ->
    @count = null

    # Set up ports
    @inPorts =
      in: new noflo.Port
      immediate: new noflo.Port 'boolean'
      reset: new noflo.Port 'bang'
    @outPorts =
      count: new noflo.Port 'number'
      out: new noflo.Port

    #
    @immediate = false
    @inPorts.immediate.on 'data', (value) =>
      @immediate = value

    # When receiving data from IN port
    @inPorts.in.on 'data', (data) =>
      # Prepare and increment counter
      @count = 0 if @count is null
      @count++
      # Forward the data packet to OUT
      @outPorts.out.send data if @outPorts.out.isAttached()
      @sendCount() if @immediate

    # When receiving bang on the reset, reset COUNT to zero
    @inPorts.reset.on 'data', (data) =>
      @count = 0

    # When IN port disconnects we send the COUNT
    @inPorts.in.on 'disconnect', =>
      @sendCount() unless @immediate
      @outPorts.out.disconnect() if @outPorts.out.isAttached()
      @count = null

  sendCount: () ->
    return unless @outPorts.count.isAttached()
    @outPorts.count.send @count
    @outPorts.count.disconnect()


exports.getComponent = -> new Counter
