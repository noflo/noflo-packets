noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Compact component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Compact', (err, instance) ->
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

  describe 'when receiving a mixed stream of packets', ->
    @timeout 30000
    it 'should only return the "proper" ones', (done) ->
      expected = [
        'DATA 1'
        'DATA 2'
        'DATA false'
      ]
      received = []

      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      #ins.post new noflo.IP 'openBracket'
      #ins.post new noflo.IP 'openBracket'
      ins.send []
      ins.send 1
      ins.send ''
      ins.send 2
      ins.send null
      ins.send false
      ins.send {}
      #ins.post new noflo.IP 'closeBracket'
      #ins.post new noflo.IP 'closeBracket'
      ##ins.post new noflo.IP 'closeBracket'
      ins.disconnect()
