noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Flatten component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Flatten', (err, instance) ->
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

  describe 'given some grouped IP structure', ->
    it 'should produce a flattened structure', (done) ->
      expected = [
        '< a'
        'DATA 1'
        '>'
        '< b'
        'DATA 2'
        '>'
        '< c'
        'DATA 3'
        '>'
      ]
      received = []

      out.on 'begingroup', (group) ->
        received.push "< #{group}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        return unless received.length >= expected.length
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.endGroup()
      ins.beginGroup 'b'
      ins.send 2
      ins.endGroup()
      ins.beginGroup 'c'
      ins.send 3
      ins.endGroup()
      ins.disconnect()

  describe 'given nested grouped IP structure', ->
    it 'should produce a flattened structure', (done) ->
      expected = [
        '< a'
        'DATA 1'
        '>'
        '< b'
        'DATA 2'
        '>'
        '< c'
        'DATA 3'
        '>'
      ]
      received = []

      out.on 'begingroup', (group) ->
        received.push "< #{group}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        return unless received.length >= expected.length
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.beginGroup 'b'
      ins.send 2
      ins.beginGroup 'c'
      ins.send 3
      ins.endGroup()
      ins.endGroup()
      ins.endGroup()
      ins.disconnect()
