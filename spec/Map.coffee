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

  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Map', (err, instance) ->
      return done err if err
      c = instance
      done()

  beforeEach ->
    ins = noflo.internalSocket.createSocket()
    map = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.data.attach ins
    c.inPorts.map.attach map
    c.outPorts.data.attach out

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

  describe.skip 'when configured', ->
    it 'accepts maps as objects', ->
      map.send { true: 'wow', false: 'meh' }
      chai.expect(c.map).to.deep.equal { true: 'wow', false: 'meh' }
    it 'accepts maps as string', ->
      map.send 'true: wow, false: meh'
      chai.expect(c.map).is.not.empty
      chai.expect(c.map[true]).is.equal 'wow'
      chai.expect(c.map[false]).is.equal 'meh'
