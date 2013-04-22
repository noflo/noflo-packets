tests = require("tests/setup")

exports["merges IPs into one array per connection"] = (test) ->
  [c, [ins], [out]] = tests.setup("Arrayify", ["in"], ["out"])

  test.expect(1)

  expected = [
    { a: 1 }
    { b: 2 }
    { c: 3 }
  ]

  out.on "data", (data) ->
    test.deepEqual(data, expected)

  out.on "disconnect", ->
    test.done()

  ins.connect()
  ins.beginGroup("a")
  ins.send(expected[0])
  ins.send(expected[1])
  ins.send(expected[2])
  ins.endGroup()
  ins.disconnect()

exports["also makes a single packet into an array"] = (test) ->
  [c, [ins], [out]] = tests.setup("Arrayify", ["in"], ["out"])

  test.expect(1)

  out.on "data", (data) ->
    test.deepEqual(data, [1])

  out.on "disconnect", ->
    test.done()

  ins.connect()
  ins.send(1)
  ins.disconnect()

exports["only arrayifies connections that have not been arrayified"] = (test) ->
  [c, [ins], [out]] = tests.setup("Arrayify", ["in"], ["out"])

  test.expect(1)

  expected = [
    { a: 1 }
    { b: 2 }
    { c: 3 }
  ]

  out.on "data", (data) ->
    test.deepEqual(data, expected)

  out.on "disconnect", ->
    test.done()

  ins.connect()
  ins.beginGroup("a")
  ins.send(expected)
  ins.endGroup()
  ins.disconnect()
