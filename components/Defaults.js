import { Component } from "@noflo/noflo";

/**
 * If the incoming stream is short of the number of default packets, the
 * missing positions are filled from the `default` port values.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "if incoming is short of the length of the default packets, send the default packets.",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
      default: { datatype: "all" },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  /** @type {unknown[]} */
  const defaults = [];
  /** @type {unknown[][]} */
  const bracketBuffers = [];
  c.tearDown = async () => {
    defaults.length = 0;
    bracketBuffers.length = 0;
  };

  c.process((input, output) => {
    if (input.hasData("default")) {
      defaults.push(input.getData("default"));
      output.done();
      return;
    }
    if (!input.has("in")) {
      return;
    }
    const ip = /** @type {import("@noflo/noflo").IP} */ (input.get("in"));
    if (ip.type === "openBracket") {
      bracketBuffers.push([]);
      output.sendDone({ out: ip });
      return;
    }
    if (ip.type === "closeBracket") {
      const packets = /** @type {unknown[]} */ (bracketBuffers.pop());
      const defaulted = defaults.map((def, idx) =>
        packets[idx] != null ? packets[idx] : def,
      );
      for (const def of defaulted) {
        output.send({ out: def });
      }
      output.sendDone({ out: ip });
      return;
    }

    if (!bracketBuffers.length) {
      // Unbracketed packet
      const data = ip.data != null ? ip.data : defaults[0];
      output.sendDone({ out: data });
      return;
    }

    bracketBuffers[bracketBuffers.length - 1].push(ip.data);
    output.done();
  });

  return c;
}
