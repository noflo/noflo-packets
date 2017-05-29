noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'FilterPackets component', ->
  c = null
  regexp = null
  ins = null
  out = null
  passthru = null
  missed = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/FilterPackets', (err, instance) ->
      return done err if err
      c = instance
      regexp = noflo.internalSocket.createSocket()
      c.inPorts.regexp.attach regexp
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    passthru = noflo.internalSocket.createSocket()
    c.outPorts.passthru.attach passthru
    missed = noflo.internalSocket.createSocket()
    c.outPorts.missed.attach missed
  afterEach ->
    c.outPorts.out.detach out
    c.outPorts.passthru.detach passthru
    c.outPorts.missed.detach missed

  describe 'given some regexp strings', ->
    it 'should send matches to out and missed to missed', (done) ->
      expected = [
        'out abe'
        'passthru abe'
        'missed afg'
        'passthru afg'
        'missed dfg'
        'passthru dfg'
        'out dc'
        'passthru dc'
      ]
      received = []

      out.on 'data', (data) ->
        received.push "out #{data}"
      passthru.on 'data', (data) ->
        received.push "passthru #{data}"
      missed.on 'data', (data) ->
        received.push "missed #{data}"
      passthru.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      regexp.connect()
      regexp.send '^ab'
      regexp.send 'c$'
      regexp.disconnect()

      ins.connect()
      ins.beginGroup 1
      ins.send 'abe'
      ins.send 'afg'
      ins.send 'dfg'
      ins.send 'dc'
      ins.endGroup()
      ins.disconnect()
