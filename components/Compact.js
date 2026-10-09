import { Component } from "@noflo/noflo";

/**
 * Passes through non-empty values: drops null/undefined, empty arrays,
 * and empty objects.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Remove null",
    inPorts: {
      in: { datatype: "all", required: true },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    if (data == null) {
      output.done();
      return;
    }
    if (data.length === 0) {
      output.done();
      return;
    }
    if (
      typeof data === "object" &&
      !Array.isArray(data) &&
      Object.keys(data).length === 0
    ) {
      output.done();
      return;
    }
    output.sendDone({ out: data });
  });

  return c;
}
