import { Component } from "@noflo/noflo";

/**
 * Sends only packets that are unique so far; duplicates go to the
 * `duplicate` port. A bang on `clear` forgets the seen values. Per scope.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Send only packets that are unique",
    icon: "filter",
    inPorts: {
      in: { datatype: "all", required: true },
      clear: { datatype: "bang" },
    },
    outPorts: {
      out: { datatype: "all" },
      duplicate: { datatype: "all" },
    },
  });

  /** @type {Map<string, unknown[]>} */
  const seen = new Map();
  c.tearDown = async () => {
    seen.clear();
  };

  c.process((input, output) => {
    const key = input.scope ?? "null";
    if (input.hasData("clear")) {
      input.getData("clear");
      seen.delete(key);
      output.done();
      return;
    }
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    let list = seen.get(key);
    if (!list) {
      list = [];
      seen.set(key, list);
    }
    if (!list.includes(data)) {
      // Unique
      output.send({ out: data });
      list.push(data);
      output.done();
      return;
    }
    output.sendDone({ duplicate: data });
  });

  return c;
}
