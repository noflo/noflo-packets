noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Defaults component', ->
  c = null
  defaults = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Defaults', (err, instance) ->
      return done err if err
      c = instance
      defaults = noflo.internalSocket.createSocket()
      c.inPorts.default.attach defaults
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach (done) ->
    c.outPorts.out.detach out
    c.tearDown done

  describe 'with some defaults', ->
    it 'should get defaults filled in in place of missing values', (done) ->
      expected = [
        '< 1'
        'DATA x'
        'DATA b'
        'DATA c'
        'DATA d'
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

      defaults.connect()
      defaults.send 'a'
      defaults.send 'b'
      defaults.send 'c'
      defaults.send 'd'
      defaults.disconnect()

      ins.connect()
      ins.beginGroup 1
      ins.send 'x'
      ins.send null
      ins.endGroup()
      ins.disconnect()

  describe 'with some defaults and grouped IPs', ->
    it 'should get defaults filled in for each group level', (done) ->
      expected = [
        '< 1'
        '< group'
        'DATA x'
        'DATA b'
        'DATA c'
        'DATA d'
        '>'
        'DATA y'
        'DATA b'
        'DATA c'
        'DATA d'
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

      defaults.connect()
      defaults.send 'a'
      defaults.send 'b'
      defaults.send 'c'
      defaults.send 'd'
      defaults.disconnect()

      ins.connect()
      ins.beginGroup '1'
      ins.beginGroup 'group'
      ins.send 'x'
      ins.endGroup()
      ins.send 'y'
      ins.endGroup()
      ins.disconnect()
