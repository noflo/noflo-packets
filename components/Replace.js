import { Component } from "@noflo/noflo";

/**
 * Replaces incoming packets with configured replacement values when they
 * match. `match` and `replace` values are paired by order. Per scope.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Replace incoming packets with something else if they match certain packets",
    icon: "clipboard",
    inPorts: {
      in: { datatype: "all", required: true },
      match: { datatype: "all" },
      replace: { datatype: "all" },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  /** @type {Map<string, unknown[]>} */
  const matches = new Map();
  /** @type {Map<string, unknown[]>} */
  const replacements = new Map();
  c.tearDown = async () => {
    matches.clear();
    replacements.clear();
  };

  c.process((input, output) => {
    const key = input.scope ?? "null";
    if (input.hasData("match")) {
      let list = matches.get(key);
      if (!list) {
        list = [];
        matches.set(key, list);
      }
      list.push(input.getData("match"));
      output.done();
      return;
    }
    if (input.hasData("replace")) {
      let list = replacements.get(key);
      if (!list) {
        list = [];
        replacements.set(key, list);
      }
      list.push(input.getData("replace"));
      output.done();
      return;
    }
    if (!input.hasData("in")) {
      return;
    }
    let data = input.getData("in");
    const matchList = matches.get(key);
    const replacementList = replacements.get(key);
    if (matchList && replacementList) {
      const index = matchList.indexOf(data);
      if (index !== -1) {
        // Send replacement
        data = replacementList[index];
      }
    }
    output.sendDone({ out: data });
  });

  return c;
}
