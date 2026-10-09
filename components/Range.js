import { Component } from "@noflo/noflo";

/**
 * Forwards only a specified number of packets of each stream, selected
 * by `start`/`end`/`length` controls. Position counters persist across
 * consecutive unbracketed packets (each would otherwise be its own
 * complete stream in 2.x) and reset at every bracket.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "only forward a specified number of packets in a stream",
    icon: "filter",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
      start: { datatype: "int", control: true },
      end: { datatype: "int", control: true },
      length: { datatype: "int", control: true },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  /** @type {Map<string, { sent: number, total: number }>} */
  const counters = new Map();
  c.tearDown = async () => {
    counters.clear();
  };

  c.process((input, output) => {
    if (!input.hasStream("in")) {
      return;
    }
    const packets = /** @type {import("@noflo/noflo").IP[]} */ (
      input.getStream("in")
    );
    let start = Number.NEGATIVE_INFINITY;
    if (input.hasData("start")) {
      start = Number.parseInt(input.getData("start"), 10);
    }
    let end = Number.POSITIVE_INFINITY;
    if (input.hasData("end")) {
      end = Number.parseInt(input.getData("end"), 10);
    }
    let length = Number.POSITIVE_INFINITY;
    if (input.hasData("length")) {
      length = Number.parseInt(input.getData("length"), 10);
    }
    const key = input.scope ?? "null";
    let state = counters.get(key);
    if (!state) {
      state = { sent: 0, total: 0 };
      counters.set(key, state);
    }
    for (const ip of packets) {
      if (ip.type === "openBracket" || ip.type === "closeBracket") {
        // Each bracketed stream counts from its own beginning
        state.sent = 0;
        state.total = 0;
        output.send({ out: ip });
        continue;
      }
      state.total += 1;
      if (state.total > start && state.total < end && state.sent < length) {
        output.send({ out: ip });
        state.sent += 1;
      }
    }
    output.done();
  });

  return c;
}
