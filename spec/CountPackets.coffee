noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'CountPackets component', ->
  c = null
  ins = null
  out = null
  count = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/CountPackets', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    count = noflo.internalSocket.createSocket()
    c.outPorts.count.attach count
  afterEach ->
    c.outPorts.out.detach out
    c.outPorts.count.detach count

  describe 'given some IPs', ->
    it 'should forward them and return a correct number', (done) ->
      expected = [
        'a'
        'b'
        'c'
        'd'
      ]
      received = []

      out.on 'data', (data) ->
        received.push data

      count.on 'data', (data) ->
        chai.expect(data).to.equal expected.length
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup '1'
      ins.send 'a'
      ins.send 'b'
      ins.send 'c'
      ins.send 'd'
      ins.endGroup()
      ins.disconnect()

  describe 'given some IPs in groups', ->
    it 'should forward them and return correct number per each group', (done) ->
      expectedOut = [
        '< '
        '< '
        'DATA a'
        'DATA b'
        '>'
        '< '
        'DATA c'
        '>'
        'DATA d'
        '>'
      ]
      receivedOut = []
      expectedCount = [
        '< '
        '< '
        'DATA 2'
        '>'
        '< '
        'DATA 1'
        '>'
        'DATA 1'
        '>'
      ]
      receivedCount = []

      out.on 'begingroup', (group) ->
        receivedOut.push "< #{group}"
      out.on 'data', (data) ->
        receivedOut.push "DATA #{data}"
      out.on 'endgroup', ->
        receivedOut.push '>'
      count.on 'begingroup', (group) ->
        receivedCount.push "< #{group}"
      count.on 'data', (data) ->
        receivedCount.push "DATA #{data}"
      count.on 'endgroup', ->
        receivedCount.push '>'
      count.on 'disconnect', ->
        setTimeout ->
          chai.expect(receivedCount).to.eql expectedCount
          chai.expect(receivedOut).to.eql expectedOut
          done()
        , 1

      ins.connect()
      ins.beginGroup ''
      ins.beginGroup ''
      ins.send 'a'
      ins.send 'b'
      ins.endGroup()
      ins.beginGroup ''
      ins.send 'c'
      ins.endGroup()
      ins.send 'd'
      ins.endGroup()
      ins.disconnect()
