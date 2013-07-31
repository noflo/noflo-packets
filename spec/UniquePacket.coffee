noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  UniquePacket = require '../components/UniquePacket.coffee'
else
  UniquePacket = require 'noflo-adapters/components/UniquePacket.js'

describe 'UniquePacket component', ->
  c = null
  ins = null
  out = null

  beforeEach ->
    c = UniquePacket.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'unique', ->
    it 'test all unique', (done) ->
      packets = ['one', 'two', 'three']

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send 'one'
      ins.send 'two'
      ins.send 'three'
      ins.disconnect()

    it 'test two unique', (done) ->
      packets = ['one', 'two']

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send 'one'
      ins.send 'one'
      ins.send 'two'
      ins.disconnect()
