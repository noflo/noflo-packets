noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'SendWith component', ->
  c = null
  filter = null
  ins = null
  withIn = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/SendWith', (err, instance) ->
      return done err if err
      c = instance
      withIn = noflo.internalSocket.createSocket()
      c.inPorts.with.attach withIn
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out
    out = null

  describe 'given some packets to always send with the incoming', ->
    it 'should send both incoming and sent-with packets', (done) ->
      expected = [
        '< a'
        'DATA 1'
        'DATA 2'
        'DATA 3'
        'DATA 4'
        'DATA 5'
        'DATA 6'
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

      withIn.connect()
      withIn.send 4
      withIn.send 5
      withIn.send 6
      withIn.disconnect()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.send 2
      ins.send 3
      ins.endGroup()
      ins.disconnect()
