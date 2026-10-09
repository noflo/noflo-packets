import { Component } from "@noflo/noflo";

/**
 * Routes packets to `even`/`odd` by their arrival position within the
 * scope: first packet is odd, second even, and so on. Per scope.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Send packets whose position upon receipt is even to the EVEN port, otherwise the ODD port.",
    icon: "code-fork",
    inPorts: {
      in: { datatype: "all", required: true },
    },
    outPorts: {
      odd: { datatype: "all" },
      even: { datatype: "all" },
    },
  });

  /** @type {Map<string, number>} */
  const counts = new Map();
  c.tearDown = async () => {
    counts.clear();
  };

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    const key = input.scope ?? "null";
    let count = counts.get(key);
    if (!count) {
      count = 0;
    }
    count += 1;
    counts.set(key, count);
    if (count % 2 === 0) {
      output.sendDone({ even: data });
      return;
    }
    output.sendDone({ odd: data });
  });

  return c;
}
