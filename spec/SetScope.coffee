noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'SetScope component', ->
  c = null
  ins = null
  scope = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/SetScope', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      scope = noflo.internalSocket.createSocket()
      c.inPorts.scope.attach scope
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out
    out = null

  describe 'when receiving a packet and a scope', ->
    it 'should set the scope', (done) ->
      out.on 'ip', (ip) ->
        chai.expect(ip.type).to.equal 'data'
        chai.expect(ip.data).to.eql
          foo: 'bar'
        chai.expect(ip.scope).to.equal 3
        done()
      ins.send
        foo: 'bar'
      scope.send 3
