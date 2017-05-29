noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Unzip component', ->
  c = null
  ins = null
  odd = null
  even = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Unzip', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    odd = noflo.internalSocket.createSocket()
    c.outPorts.odd.attach odd
    even = noflo.internalSocket.createSocket()
    c.outPorts.even.attach even
  afterEach ->
    c.outPorts.odd.detach odd
    odd = null
    c.outPorts.even.detach even
    even = null

  describe 'given some IPs', ->
    it 'should route them to ODD and EVEN based on packet position', (done) ->
      expected = [
        'odd 1'
        'even 2'
        'odd 3'
        'even 4'
      ]
      received = []

      odd.on 'data', (data) ->
        received.push "odd #{data}"
      even.on 'data', (data) ->
        received.push "even #{data}"
      even.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.send 2
      ins.send 3
      ins.send 4
      ins.endGroup()
      ins.disconnect()

  describe 'given some IPs with groups', ->
    it 'should route them to ODD and EVEN ignoring groups', (done) ->
      expected = [
        'odd < group'
        'odd 1'
        'even < group'
        'even 2'
        'odd 3'
        'even 4'
        'odd >'
        'even >'
      ]
      received = []

      odd.on 'begingroup', (group) ->
        received.push "odd < #{group}"
      odd.on 'data', (data) ->
        received.push "odd #{data}"
      odd.on 'endgroup', ->
        received.push 'odd >'
      even.on 'begingroup', (group) ->
        received.push "even < #{group}"
      even.on 'data', (data) ->
        received.push "even #{data}"
      even.on 'endgroup', ->
        received.push 'even >'
      even.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.connect()
      ins.beginGroup 'group'
      ins.send 1
      ins.send 2
      ins.send 3
      ins.send 4
      ins.endGroup()
      ins.disconnect()
