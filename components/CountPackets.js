import { Component } from "@noflo/noflo";

/**
 * Counts the number of data IPs inside each stream and mirrors the
 * bracket structure on the `count` port, with counts as data IPs. The
 * counter is instance-level, not scope-aware (as in 1.x).
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Count number of data IPs inside each stream",
    icon: "sort-numeric-asc",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
    },
    outPorts: {
      out: { datatype: "all" },
      count: { datatype: "int" },
    },
  });

  /** @type {number[]} */
  const counts = [0];
  c.tearDown = async () => {
    counts.length = 0;
    counts.push(0);
  };

  c.process((input, output) => {
    if (!input.has("in")) {
      return;
    }
    const ip = /** @type {import("@noflo/noflo").IP} */ (input.get("in"));
    if (ip.type === "openBracket") {
      counts.push(0);
      output.sendDone({ out: ip, count: ip.clone() });
      return;
    }
    if (ip.type === "closeBracket") {
      const count = counts[counts.length - 1];
      counts.pop();
      output.send({ count });
      output.sendDone({ out: ip, count: ip.clone() });
      return;
    }
    // Data packet, add to count
    counts[counts.length - 1] += 1;
    // Forward packet
    output.send({ out: ip });

    if (counts.length === 1) {
      // Non-bracketed IP, send count
      output.send({ count: counts[counts.length - 1] });
      counts[counts.length - 1] = 0;
    }

    output.done();
  });

  return c;
}
