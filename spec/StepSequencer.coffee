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
      done()

  beforeEach ->
    pattern = noflo.internalSocket.createSocket()
    c.inPorts.pattern.attach pattern
    value = noflo.internalSocket.createSocket()
    c.outPorts.value.attach value

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.pattern).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.value).to.be.an 'object'

  describe.skip 'when receiving empty pattern', ->
    it 'does nothing', ->
      pattern.send ''
      chai.expect(c.pattern).to.have.length 0

  describe 'when receiving pattern', ->
    it 'parses timestamp-values', ->
      value.once 'data', (res) ->
        console.log res
      pattern.send '0,5,10,7'
      #chai.expect(c.pattern).to.have.length 4
    it 'sends single value', (done) ->
      value.once 'data', (res) ->
        chai.expect(res).to.be.equal '5'
        done()
      pattern.send '0,5'

