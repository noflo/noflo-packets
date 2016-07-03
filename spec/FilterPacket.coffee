noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'FilterPacket component', ->
  c = null
  ins = null
  regexp = null
  out = null
  missed = null

  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/FilterPacket', (err, instance) ->
      return done err if err
      c = instance
      done()

  beforeEach ->
    ins = noflo.internalSocket.createSocket()
    regexp = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    missed = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.regexp.attach regexp
    c.outPorts.out.attach out
    c.outPorts.missed.attach missed
  afterEach ->
    c.outPorts.out.detach out
    c.outPorts.missed.detach missed

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  it 'test default behavior', (done) ->
    packets = ['hello world']

    out.on 'data', (data) ->
      console.log data
      chai.expect(packets.shift()).to.deep.equal data
    out.on 'disconnect', ->
      chai.expect(packets.length).to.equal 0
      done()

    ins.connect()
    ins.send 'hello world'
    ins.disconnect()

  it 'test accept via regexp', (done) ->
    packets = ['grue', true]

    out.on 'data', (data) ->
      chai.expect(packets.shift()).to.deep.equal data
    out.on 'disconnect', ->
      chai.expect(packets.length).to.equal 0
      done()

    regexp.send '[tg]rue'

    ins.connect()
    ins.send "grue"
    ins.send false
    ins.send "foo"
    ins.send true
    ins.disconnect()
