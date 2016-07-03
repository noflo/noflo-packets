noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'UniquePacket component', ->
  c = null
  ins = null
  out = null

  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/UniquePacket', (err, instance) ->
      return done err if err
      c = instance
      done()

  beforeEach ->
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

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
        if packets.length is 0
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
        if packets.length is 0
          done()

      ins.connect()
      ins.send 'one'
      ins.send 'one'
      ins.send 'two'
      ins.disconnect()
