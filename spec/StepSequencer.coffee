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
  afterEach ->
    c.outPorts.value.detach value

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
    it 'parses timestamp-values', (done) ->
      @timeout 20000
      expect = ['5', '7']
      value.on 'data', (res) ->
        chai.expect(res).to.equal expect.shift()
        return unless expect.length is 0
        done()
      pattern.send '0,5,10,7'
    it 'sends single value', (done) ->
      value.once 'data', (res) ->
        chai.expect(res).to.be.equal '5'
        done()
      pattern.send '0,5'

