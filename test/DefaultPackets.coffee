tests = require("tests/setup")

exports["fills up the rest of outport when short of data packets or null value is passed"] = (test) ->
  [c, [ins, def], [out]] =
    tests.setup("DefaultPackets", ["in", "default"], ["out"])

  output = []

  out.on "data", (data) ->
    output.push(data)

  out.on "disconnect", ->
    test.deepEqual(output, ["x", "b", "c", "d"])
    test.done()

  def.connect()
  def.send("a")
  def.send("b")
  def.send("c")
  def.send("d")
  def.disconnect()

  ins.connect()
  ins.send("x")
  ins.send(null)
  ins.disconnect()
