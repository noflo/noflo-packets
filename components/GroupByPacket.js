import { Component, IP } from "@noflo/noflo";

/**
 * Surrounds each data packet by a bracket whose name is the packet's
 * position within its stream. The position persists across consecutive
 * unbracketed packets (each would otherwise be its own complete stream
 * in 2.x) and resets at every bracket.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Surround each data packet by a bracket",
    icon: "indent",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  /** @type {Map<string, number>} */
  const positions = new Map();
  c.tearDown = async () => {
    positions.clear();
  };

  c.process((input, output) => {
    if (!input.hasStream("in")) {
      return;
    }
    const packets = /** @type {import("@noflo/noflo").IP[]} */ (
      input.getStream("in")
    );
    const key = input.scope ?? "null";
    for (const ip of packets) {
      if (ip.type === "openBracket") {
        positions.set(key, 0);
        output.send({ out: ip });
        continue;
      }
      if (ip.type === "closeBracket") {
        output.send({ out: ip });
        continue;
      }
      const position = positions.get(key) ?? 0;
      // Surround data packet with a new bracket telling position in stream
      output.send({ out: new IP("openBracket", position) });
      output.send({ out: ip });
      output.send({ out: new IP("closeBracket", position) });
      positions.set(key, position + 1);
    }
    output.done();
  });

  return c;
}
