import { Component } from "@noflo/noflo";

/**
 * Splits numeric packets into `lower`, `higher`, and `equal` streams
 * relative to the `filtervalue` control.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Filter packets based on their value",
    icon: "filter",
    inPorts: {
      in: { datatype: "number", required: true },
      filtervalue: {
        datatype: "number",
        control: true,
        required: true,
      },
    },
    outPorts: {
      lower: { datatype: "number" },
      higher: { datatype: "number" },
      equal: { datatype: "number" },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in", "filtervalue")) {
      return;
    }
    const filterValue = input.getData("filtervalue");
    const data = input.getData("in");

    if (data < filterValue) {
      output.sendDone({ lower: data });
      return;
    }
    if (data > filterValue) {
      output.sendDone({ higher: data });
      return;
    }
    if (data === filterValue) {
      output.sendDone({ equal: data });
      return;
    }
    output.done();
  });

  return c;
}
