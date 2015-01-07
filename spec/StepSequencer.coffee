noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  module = require '../components/StepSequencer.coffee'
else
  module = require 'noflo-vv1/components/StepSequencer.js'

describe 'StepSequencer component', ->
  c = null
  pattern = null
  value = null

  beforeEach ->
    c = module.getComponent()
    pattern = noflo.internalSocket.createSocket()
    c.inPorts.pattern.attach pattern
    value = noflo.internalSocket.createSocket()
    c.outPorts.value.attach value

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.pattern).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.value).to.be.an 'object'

  describe 'when receiving empty pattern', ->
    it 'does nothing', ->
      pattern.send ''
      chai.expect(c.pattern).to.have.length 0

  describe 'when receiving pattern', ->
    it 'parses timestamp-values', ->
      pattern.send '0,5,10,7'
      chai.expect(c.pattern).to.have.length 4
    it 'sends single value', (done) ->
      value.once 'data', (res) ->
        chai.expect(res).to.be.equal '5'
        done()
      pattern.send '0,5'

