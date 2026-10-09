import { Component } from "@noflo/noflo";

/**
 * Filters stream packets by position: a boolean sequence on the `filter`
 * port decides, position by position, which data packets pass. The
 * position persists across consecutive unbracketed packets (each would
 * otherwise be its own complete stream in 2.x) and resets at every
 * bracket.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Filter packets based on their positions",
    icon: "filter",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
      filter: { datatype: "boolean" },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  /** @type {boolean[]} */
  const filters = [];
  /** @type {Map<string, number>} */
  const positions = new Map();
  c.tearDown = async () => {
    filters.length = 0;
    positions.clear();
  };

  c.process((input, output) => {
    if (input.hasData("filter")) {
      filters.push(input.getData("filter"));
      output.done();
      return;
    }
    if (!input.hasStream("in")) {
      return;
    }
    const packets = /** @type {import("@noflo/noflo").IP[]} */ (
      input.getStream("in")
    );
    const key = input.scope ?? "null";
    for (const ip of packets) {
      if (ip.type === "openBracket" || ip.type === "closeBracket") {
        // Each bracketed stream counts positions from its own beginning
        positions.set(key, 0);
        output.send({ out: ip });
        continue;
      }
      let position = positions.get(key);
      if (position === undefined) {
        position = 0;
      }
      if (!filters[position]) {
        // Data packet filtered out
        positions.set(key, position + 1);
        continue;
      }
      output.send({ out: ip });
      positions.set(key, position + 1);
    }
    output.done();
  });

  return c;
}
