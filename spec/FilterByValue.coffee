noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'FilterByValue component', ->
  c = null
  filter = null
  ins = null
  lower = null
  higher = null
  equal = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/FilterByValue', (err, instance) ->
      return done err if err
      c = instance
      filter = noflo.internalSocket.createSocket()
      c.inPorts.filtervalue.attach filter
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    lower = noflo.internalSocket.createSocket()
    c.outPorts.lower.attach lower
    higher = noflo.internalSocket.createSocket()
    c.outPorts.higher.attach higher
    equal = noflo.internalSocket.createSocket()
    c.outPorts.equal.attach equal
  afterEach ->
    c.outPorts.lower.detach lower
    c.outPorts.higher.detach higher
    c.outPorts.equal.detach equal

  describe 'given the value to filter by', ->
    it 'it should split the stream by value compared to filter', (done) ->
      expected = [
        'lower 0'
        'equal 1'
        'higher 2'
        'higher 1.5'
        'lower 0.5'
      ]
      received = []

      lower.on 'data', (data) ->
        console.log 'lower'
        received.push "lower #{data}"

        return unless expected.length is received.length
        chai.expect(received).to.eql expected
        done()

      higher.on 'data', (data) ->
        console.log 'higher'
        received.push "higher #{data}"
        return unless expected.length is received.length
        chai.expect(received).to.eql expected
        done()
      equal.on 'data', (data) ->
        console.log 'equal...'
        received.push "equal #{data}"
        return unless expected.length is received.length
        chai.expect(received).to.eql expected
        done()

      filter.connect()
      filter.send 1
      filter.disconnect()

      ins.connect()
      ins.send 0
      ins.send 1
      ins.send 2
      ins.send 1.5
      ins.send 0.5
      ins.disconnect()
