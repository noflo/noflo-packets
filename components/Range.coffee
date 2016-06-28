noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    description: 'only forward a specified number of packets in a connection'
    inPorts:
      in:
        datatype: 'all'
        data: true
      start:
        datatype: 'all'
        control: true
        default: -99999999
      end:
        datatype: 'all'
        control: true
        default: 99
      length:
        datatype: 'all'
        control: true
        default: 99999999
    outPorts:
      out:
        datatype: 'all'

  c.process (input, output) ->
    return unless input.hasDataStream 'in'

    stream = input.getDataStream 'in'
      .filter (data) -> data?

    length = parseInt input.getDataStream('length')[0]
    start = input.getDataStream('start')[0]
    end = input.getDataStream('end')[0]

    end = if end? then parseInt(end) else 9999999 #Infinity
    length = if length? then parseInt(length) else 99999999 #Infinity
    start = if start? then parseInt(start) else -99999999 #-Infinity

    length = 99999999 if Number.isNaN(length)
    start = -99999999 if Number.isNaN(start)
    end = 99999999 if Number.isNaN(end)

    totalCount = 0
    sentCount = 0

    for data in stream
      totalCount++
      if totalCount > start and
         totalCount < end and
         sentCount < length
        sentCount++
        ip = new noflo.IP('data', data)
        output.ports.out.sendIP ip, null, {}, null, false
        # output.sendIP 'out', ip, false

    c.outPorts.out.disconnect()
    output.done()
