noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Map component', ->
  c = null
  ins = null
  map = null
  out = null
  loader = null
  before ->
    loader = new noflo.ComponentLoader baseDir
  beforeEach (done) ->
    @timeout 4000
    loader.load 'packets/Map', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      map = noflo.internalSocket.createSocket()
      out = noflo.internalSocket.createSocket()
      c.inPorts.data.attach ins
      c.inPorts.map.attach map
      c.outPorts.data.attach out
      done()

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.data).to.be.an 'object'
    it 'should have input ports', ->
      chai.expect(c.inPorts.map).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.data).to.be.an 'object'

  describe 'maps packets', ->
    m = { true: 'wow', false: 'meh' }
    
    it 'to map values for known keys', (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [ 'wow' ]
        done()
      map.send { true: 'wow', false: 'meh' }
      ins.send true
      ins.disconnect()

    it 'to inputs for unknown keys', (done) ->
      output = []
      out.on "data", (data) ->
        output.push data
      out.once "disconnect", ->
        chai.expect(output).to.deep.equal [ 'hello' ]
        done()
      map.send { true: 'wow', false: 'meh' }
      ins.send 'hello'
      ins.disconnect()
