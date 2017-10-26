noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'GetScope component', ->
  c = null
  ins = null
  scope = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/GetScope', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    scope = noflo.internalSocket.createSocket()
    c.outPorts.scope.attach scope
  afterEach ->
    c.outPorts.out.detach out
    out = null
    c.outPorts.scope.detach scope
    scope = null

  describe 'when receiving a packet', ->
    it 'should send the scope', (done) ->
      scopeReceived = false
      dataReceived = false
      scope.on 'ip', (ip) ->
        chai.expect(ip.type).to.equal 'data'
        chai.expect(ip.data).to.eql 3
        scopeReceived = true
        return unless dataReceived
        done()
      out.on 'ip', (ip) ->
        chai.expect(ip.type).to.equal 'data'
        chai.expect(ip.data).to.eql
          foo: 'bar'
        dataReceived = true
        return unless scopeReceived
        done()
      ins.send new noflo.IP 'data',
        foo: 'bar'
      ,
        scope: 3
