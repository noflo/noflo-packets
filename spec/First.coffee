noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'First component', ->
  c = null
  ins = null
  out = null
  count = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/First', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      c.start done
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'given a single IP', ->
    it 'should send it out', (done) ->
      expected = [
        '"a"'
      ]
      received = []
      out.on 'ip', (ip) ->
        if ip.type is 'openBracket'
          received.push '<'
        if ip.type is 'data'
          received.push JSON.stringify ip.data
        if ip.type is 'closeBracket'
          received.push '>'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.send 'a'

  describe 'given a single IP in brackets', ->
    it 'should send it out', (done) ->
      expected = [
        '<'
        '"a"'
        '>'
      ]
      received = []
      out.on 'ip', (ip) ->
        if ip.type is 'openBracket'
          received.push '<'
        if ip.type is 'data'
          received.push JSON.stringify ip.data
        if ip.type is 'closeBracket'
          received.push '>'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.beginGroup()
      ins.send 'a'
      ins.endGroup()

  describe 'given multiple packets in a stream', ->
    it 'should send only first out', (done) ->
      expected = [
        '<'
        '"a"'
        '>'
      ]
      received = []
      out.on 'ip', (ip) ->
        if ip.type is 'openBracket'
          received.push '<'
        if ip.type is 'data'
          received.push JSON.stringify ip.data
        if ip.type is 'closeBracket'
          received.push '>'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.beginGroup()
      ins.send 'a'
      ins.send 'b'
      ins.send 'c'
      ins.endGroup()
