noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Range component', ->
  c = null
  start = null
  length = null
  end = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Range', (err, instance) ->
      return done err if err
      c = instance
      start = noflo.internalSocket.createSocket()
      c.inPorts.start.attach start
      length = noflo.internalSocket.createSocket()
      c.inPorts.length.attach length
      end = noflo.internalSocket.createSocket()
      c.inPorts.end.attach end
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'given a starting position and a length', ->
    it 'should take the specified packets', (done) ->
      expected = [
        'DATA 2'
        'DATA 3'
      ]
      received = []

      #out.on 'begingroup', (group) ->
      #  received.push "< #{group}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      #out.on 'endgroup', ->
      #  received.push '>'
      out.on 'disconnect', ->
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()

      start.send 1
      length.send 2

      ins.connect()
      ins.send 1
      ins.send 2
      ins.send 3
      ins.send 4
      ins.send 5
      ins.send 6
      ins.disconnect()

  describe 'given a starting position and no length', ->
    it 'should send from starting packet until the end', (done) ->
      expected = [
        'DATA 2'
        'DATA 3'
        'DATA 4'
        'DATA 5'
        'DATA 6'
      ]
      received = []

      #out.on 'begingroup', (group) ->
      #  received.push "< #{group}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      #out.on 'endgroup', ->
      #  received.push '>'
      out.on 'disconnect', ->
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()

      start.send 1

      ins.connect()
      ins.send 1
      ins.send 2
      ins.send 3
      ins.send 4
      ins.send 5
      ins.send 6
      ins.disconnect()

  describe 'given a length but no starting position', ->
    it 'should send the length of packets starting from first', (done) ->
      expected = [
        'DATA 1'
        'DATA 2'
        'DATA 3'
        'DATA 4'
      ]
      received = []

      #out.on 'begingroup', (group) ->
      #  received.push "< #{group}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      #out.on 'endgroup', ->
      #  received.push '>'
      out.on 'disconnect', ->
        return unless received.length is expected.length

        chai.expect(received).to.eql expected
        done()

      length.send 4

      ins.connect()
      ins.send 1
      ins.send 2
      ins.send 3
      ins.send 4
      ins.send 5
      ins.send 6
      ins.disconnect()

  describe 'given a starting and an ending position', ->
    it 'should send packets between the positions', (done) ->
      expected = [
        'DATA 2'
        'DATA 3'
      ]
      received = []

      #out.on 'begingroup', (group) ->
      #  received.push "< #{group}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      #out.on 'endgroup', ->
      #  received.push '>'
      out.on 'disconnect', ->
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()

      start.send 1
      end.send 4

      ins.connect()
      ins.send 1
      ins.send 2
      ins.send 3
      ins.send 4
      ins.send 5
      ins.send 6
      ins.disconnect()

  describe 'given just an ending position', ->
    it 'should send from first until the specified position', (done) ->
      expected = [
        'DATA 1'
      ]
      received = []

      #out.on 'begingroup', (group) ->
      #  received.push "< #{group}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      #out.on 'endgroup', ->
      #  received.push '>'
      out.on 'disconnect', ->
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()

      end.send 2

      ins.connect()
      ins.send 1
      ins.send 2
      ins.send 3
      ins.send 4
      ins.send 5
      ins.send 6
      ins.disconnect()
