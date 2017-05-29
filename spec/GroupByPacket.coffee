noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'GroupByPacket component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/GroupByPacket', (err, instance) ->
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

  describe 'given some IPs', ->
    it 'should group each packet by its number', (done) ->
      expected = [
        '< a'
        '< 0'
        'DATA 1'
        '>'
        '< 1'
        'DATA 2'
        '>'
        '< 2'
        'DATA 3'
        '>'
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
      ins.send 2
      ins.send 3
      ins.endGroup()
      ins.disconnect()
