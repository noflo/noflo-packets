noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'FilterByPosition component', ->
  c = null
  filter = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/FilterByPosition', (err, instance) ->
      return done err if err
      c = instance
      filter = noflo.internalSocket.createSocket()
      c.inPorts.filter.attach filter
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'given a sequence of boolean filter packets', ->
    it 'it should filter the packet stream', (done) ->
      expected = [
        '< 1'
        'DATA passed'
        'DATA passed'
        'DATA passed'
        '>'
      ]
      received = []

      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      filter.connect()
      filter.send true
      filter.send true
      filter.send false
      filter.send true
      filter.send false
      filter.send false
      filter.disconnect()

      ins.connect()
      ins.beginGroup 1
      ins.send 'passed'
      ins.send 'passed'
      ins.send 'dropped'
      ins.send 'passed'
      ins.send 'dropped'
      ins.send 'dropped'
      ins.endGroup()
      ins.disconnect()
