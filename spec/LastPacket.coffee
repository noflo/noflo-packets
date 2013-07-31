noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  LastPacket = require '../components/LastPacket.coffee'
else
  LastPacket = require 'noflo-adapters/components/LastPacket.js'

describe 'LastPacket component', ->
  c = null
  ins = null
  out = null

  beforeEach ->
    c = LastPacket.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'last packet', ->
    it 'test last', (done) ->
      packets = ['three']

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
