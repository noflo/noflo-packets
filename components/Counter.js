import { Component } from "@noflo/noflo";

/**
 * Sends the number of packets received in the current stream. Sends the
 * running count after each packet when `immediate` is set, otherwise
 * once at the end of the stream. Instance-level counter (as in 1.x).
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "send a number of packets received in a stream",
    icon: "sort-numeric-asc",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
      immediate: {
        datatype: "boolean",
        control: true,
        default: false,
      },
      reset: { datatype: "bang" },
    },
    outPorts: {
      count: { datatype: "int" },
      out: { datatype: "all" },
    },
  });

  let count = 0;
  /** @type {unknown[]} */
  const brackets = [];
  c.tearDown = async () => {
    count = 0;
    brackets.length = 0;
  };

  c.process((input, output) => {
    if (input.hasData("reset")) {
      // When receiving bang on the reset, reset COUNT to zero
      input.getData("reset");
      count = 0;
      output.done();
      return;
    }

    if (!input.has("in")) {
      return;
    }

    const ip = /** @type {import("@noflo/noflo").IP} */ (input.get("in"));
    if (ip.type === "openBracket") {
      brackets.push(ip.data);
      output.sendDone({ out: ip });
      return;
    }
    if (ip.type === "closeBracket") {
      brackets.pop();
      output.send({ out: ip });
      if (!brackets.length) {
        // Send COUNT at end of stream
        output.send({ count });
        count = 0;
      }
      output.done();
      return;
    }

    // When receiving data from IN port
    count += 1;
    // Forward the data packet to OUT
    output.send({ out: ip });

    let immediate = false;
    if (input.hasData("immediate")) {
      immediate = input.getData("immediate");
    }
    if (immediate || brackets.length === 0) {
      output.send({ count });
      if (brackets.length === 0) {
        count = 0;
      }
    }
    output.done();
  });

  return c;
}
