noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Zip component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Zip', (err, instance) ->
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

  describe 'given some arrays', ->
    it 'should send them out zipped', (done) ->
      expected = [
        'DATA [[1,"a"],[2,"b"],[3,"c"]]'
      ]
      received = []

      out.on 'begingroup', (group) ->
        received.push "< #{group}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup 'group'
      ins.send [1, 2, 3]
      ins.send ['a', 'b', 'c']
      ins.endGroup()
      ins.disconnect()

  describe 'given some arrays with groups', ->
    it 'should send them out zipped, ignoring groups', (done) ->
      expected = [
        'DATA [[1,"a"],[2,"b"],[3,"c"]]'
      ]
      received = []

      out.on 'begingroup', (group) ->
        received.push "< #{group}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup 'group'
      ins.beginGroup 'groupA'
      ins.send [1, 2, 3]
      ins.endGroup()
      ins.beginGroup 'groupB'
      ins.send ['a', 'b', 'c']
      ins.endGroup()
      ins.endGroup()
      ins.disconnect()

  describe 'given some packets that are not arrays', ->
    it 'should send an empty array', (done) ->
      expected = [
        'DATA []'
      ]
      received = []

      out.on 'begingroup', (group) ->
        received.push "< #{group}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup 'group'
      ins.send 1
      ins.send 'a'
      ins.endGroup()
      ins.disconnect()
