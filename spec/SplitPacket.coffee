noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'SplitPacket component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/SplitPacket', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out
    out = null

  describe 'given some IPs', ->
    it 'should send each IP with its own connection', (done) ->
      expected = [
        'DATA a'
        'DATA b'
      ]
      received = []

      #out.on 'connect', ->
      #  received.push 'CONN'
      #out.on 'begingroup', (group) ->
      #  received.push "< #{group}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      #out.on 'endgroup', ->
      #  received.push '>'
      out.on 'disconnect', ->
        #received.push 'DISC'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.send 'a'
      ins.send 'b'
      ins.disconnect()

  describe 'given some grouped IPs', ->
    it 'should send only groups enclosing a particular IP', (done) ->
      expected = [
        '< x'
        'DATA a'
        '>'
        '< y'
        'DATA b'
        '>'
      ]
      received = []

      out.on 'connect', ->
        #received.push 'CONN'
      out.on 'begingroup', (group) ->
        return unless group?
        received.push "< #{group}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', (group) ->
        return unless group?
        received.push '>'
      out.on 'disconnect', ->
        #received.push 'DISC'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup 'x'
      ins.send 'a'
      ins.endGroup()
      ins.beginGroup 'y'
      ins.send 'b'
      ins.endGroup()
      ins.disconnect()
