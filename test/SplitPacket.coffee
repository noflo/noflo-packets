tests = require("tests/setup")

exports["split data IPs into its own connection"] = (test) ->
  [c, [ins], [out]] = tests.setup("SplitPacket", ["in"], ["out"])

  test.expect(4)

  count = 0
  expected = ["a", "b", "c", "d"]

  out.on "data", (data) ->
    test.equal(data, expected.shift())

  out.on "disconnect", ->
    count++
    if count is 4
      test.done()

  ins.connect()
  ins.send("a")
  ins.send("b")
  ins.send("c")
  ins.send("d")
  ins.disconnect()

exports["no residual groups"] = (test) ->
  [c, [ins], [out]] = tests.setup("SplitPacket", ["in"], ["out"])

  test.expect(2)

  count = 0
  expectedGroups = ["a", "c"]

  out.on "begingroup", (group) ->
    test.equal(group, expectedGroups.shift())

  out.on "disconnect", ->
    count++
    if count is 2
      test.done()

  ins.connect()
  ins.beginGroup("a")
  ins.send("b")
  ins.endGroup("a")
  ins.beginGroup("c")
  ins.send("d")
  ins.endGroup("c")
  ins.disconnect()
