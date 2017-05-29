noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'StepSequencer component', ->
  c = null
  pattern = null
  value = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/StepSequencer', (err, instance) ->
      return done err if err
      c = instance
      pattern = noflo.internalSocket.createSocket()
      c.inPorts.pattern.attach pattern
      done()

  beforeEach ->
    value = noflo.internalSocket.createSocket()
    c.outPorts.value.attach value
  afterEach ->
    c.outPorts.value.detach value

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.pattern).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.value).to.be.an 'object'

  describe 'when receiving empty pattern', ->
    it 'does nothing', (done) ->
      @timeout 4000
      failed = false
      value.once 'data', (res) ->
        console.log res
        done new Error 'Expected not to receive anything'
        failed = true
      pattern.send ''
      setTimeout ->
        done() unless failed
      , 50

  describe 'when receiving pattern', ->
    it 'sends single value', (done) ->
      value.once 'data', (res) ->
        chai.expect(res).to.be.equal '5'
        done()
      pattern.send '0,5'
    it 'sends multiple values', ->
      @timeout 4000
      expected = [
        5
        10
        7
      ]
      received = []
      value.on 'data', (res) ->
        received.push res
      value.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()
      pattern.send '0,5,10,7'
