import { Component, IP } from "@noflo/noflo";

/**
 * Flattens the IP structure but preserves all groups: every bracket
 * closes before the next group of the same level opens, so all groups
 * appear at the top level. State is per scope.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Flatten the IP structure but preserve all groups (i.e. all groups are at the top level)",
    icon: "list",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  /** @type {Map<string, import("@noflo/noflo").IP>} */
  const lastBracket = new Map();
  c.tearDown = async () => {
    lastBracket.clear();
  };

  c.process((input, output) => {
    if (!input.has("in")) {
      return;
    }
    const ip = /** @type {import("@noflo/noflo").IP} */ (input.get("in"));
    const key = input.scope ?? "null";
    if (ip.type === "openBracket") {
      const previous = lastBracket.get(key);
      if (previous) {
        output.send({ out: new IP("closeBracket", previous.data) });
      }
      output.send({ out: ip });
      lastBracket.set(key, ip);
      output.done();
      return;
    }
    if (ip.type === "closeBracket") {
      if (!lastBracket.has(key)) {
        output.done();
        return;
      }
      output.send({ out: ip });
      lastBracket.delete(key);
      output.done();
      return;
    }
    output.send({ out: ip });
    output.done();
  });

  return c;
}
