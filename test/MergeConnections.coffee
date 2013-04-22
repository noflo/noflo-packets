tests = require("tests/setup")

exports["merges two connections together"] = (test) ->
  [c, [ins, count], [out]] = tests.setup("MergeConnections", ["in", "count"], ["out"])

  test.expect(1)

  sum = 0

  out.on "data", (data) ->
    sum += data

  out.on "disconnect", ->
    test.equal(sum, 6)
    test.done()

  count.connect()
  count.send(2)
  count.disconnect()

  ins.connect()
  ins.send(1)
  ins.send(2)
  ins.disconnect()

  ins.connect()
  ins.send(3)
  ins.disconnect()

  ins.connect()
  ins.send(4)
  ins.disconnect()
