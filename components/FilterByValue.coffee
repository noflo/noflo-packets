noflo = require("noflo")

class FilterByValue extends noflo.Component

  description: "Filter packets based on their value"

  constructor: ->
    @filterValue = 0

    @inPorts =
      in: new noflo.Port
      filterValue: new noflo.Port
    @outPorts =
      lower: new noflo.Port
      higher: new noflo.Port
      equal: new noflo.Port

    @inPorts.filterValue.on 'data', (data) =>
      @filterValue = data

    @inPorts.in.on 'data', (data) =>
      if data < @filterValue
        @outPorts.lower.send data
      else if data > @filterValue
        @outPorts.higher.send data
      else if data == @filterValue
        @outPorts.equal.send data

    @inPorts.in.on "disconnect", =>
      @outPorts.lower.disconnect()
      @outPorts.higher.disconnect()
      @outPorts.equal.disconnect()

exports.getComponent = -> new FilterByValue
