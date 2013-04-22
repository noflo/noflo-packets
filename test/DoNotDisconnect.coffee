tests = require("tests/setup")

exports["forwards everything but never disconnect"] = (test) ->
  [c, [ins], [out]] = tests.setup("DoNotDisconnect", ["in"], ["out"])

  test.expect(1)

  out.on "disconnect", (data) ->
    test.ok(false, "should not disconnect")

  ins.connect()
  ins.send(1)
  ins.disconnect()

  ins.connect()
  ins.send(2)
  ins.disconnect()

  pass = ->
    test.ok(true)
    test.done()

  setTimeout(pass, 100)
