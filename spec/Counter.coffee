noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  Counter = require '../components/Counter.coffee'
else
  Counter = require 'noflo-adapters/components/Counter.js'

describe 'Counter component', ->
  c = null
  ins = null
  out = null
  count = null

  beforeEach ->
    c = Counter.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    count = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out
    c.outPorts.count.attach count

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
      chai.expect(c.outPorts.count).to.be.an 'object'

  describe 'counting', ->
    it 'single packet should return count of 1', (done) ->
      packets = [1]

      count.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      count.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send 'hello'
      ins.disconnect()

    it 'single packet should be forwarded', (done) ->
      packets = ['hello']

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send 'hello'
      ins.disconnect()

    it 'two packets should return count of 2', (done) ->
      packets = [2]

      count.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      count.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send 'hello'
      ins.send 'world'
      ins.disconnect()

    it 'disconnecting and sending later should start new count', (done) ->
      packets = [2, 1]

      count.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      count.on 'disconnect', ->
        done() if packets.length is 0

      ins.connect()
      ins.send 'hello'
      ins.send 'world'
      ins.disconnect()
      ins.connect()
      ins.send 'foo'
      ins.disconnect()
