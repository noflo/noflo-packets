noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Replace component', ->
  c = null
  ins = null
  match = null
  replace = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Replace', (err, instance) ->
      return done err if err
      c = instance
      match = noflo.internalSocket.createSocket()
      c.inPorts.match.attach match
      replace = noflo.internalSocket.createSocket()
      c.inPorts.replace.attach replace
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out
    out = null

  describe 'given a stream of packets and replacement data', ->
    it 'should replace certain packets', (done) ->
      expected = [
        '< a'
        'DATA 1'
        'DATA 42'
        'DATA 3'
        'DATA 36'
        'DATA 5'
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
        chai.expect(received).to.eql expected
        done()

      match.connect()
      match.send 2
      match.send 4
      match.disconnect()
      replace.connect()
      replace.send 42
      replace.send 36
      replace.disconnect()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.send 2
      ins.send 3
      ins.send 4
      ins.send 5
      ins.endGroup()
      ins.disconnect()
