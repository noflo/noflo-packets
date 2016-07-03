noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-packets'

describe 'Replace component', ->
  c = null
  ins = null
  match = null
  replace = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'packets/Replace', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      match = noflo.internalSocket.createSocket()
      replace = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      c.inPorts.match.attach match
      c.inPorts.replace.attach replace
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out

  describe 'replace', ->
    @timeout 30000
    it 'should ', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.equal 'canada'
        done()

      match.send 'eh'
      replace.send 'canada'
      ins.send 'eh'
      ins.disconnect()
