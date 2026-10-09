import { Component } from "@noflo/noflo";

/**
 * Zips multiple array IPs together the way `Array.zip` would: the first
 * element of each incoming array forms the first outgoing array, and so
 * on. Requires all connected connections to have delivered.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "zip through multiple IPs and output a series of zipped IPs just like how _.zip() works in Underscore.js",
    icon: "file-archive-o",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "array", addressable: true, required: true },
    },
    outPorts: {
      out: { datatype: "array" },
    },
  });

  /**
   * The underscore `_.zip` semantics: truncate to the shortest input,
   * fill missing values with undefined.
   * @param {unknown[][]} arrays
   * @returns {unknown[][]}
   */
  const zip = (arrays) => {
    if (!arrays.length) {
      return [];
    }
    const length = Math.min(...arrays.map((arr) => arr.length));
    /** @type {unknown[][]} */
    const zipped = [];
    for (let i = 0; i < length; i += 1) {
      zipped.push(arrays.map((arr) => arr[i]));
    }
    return zipped;
  };

  c.process((input, output) => {
    const attached = /** @type {number[]} */ (input.attached("in"));
    const indexesWithStreams = attached.filter((idx) =>
      input.hasStream(["in", idx]),
    );
    if (indexesWithStreams.length !== attached.length) {
      return;
    }
    /** @type {unknown[][]} */
    const arrays = [];
    for (const idx of indexesWithStreams) {
      const stream = /** @type {import("@noflo/noflo").IP[]} */ (
        input.getStream(["in", idx])
      );
      for (const ip of stream) {
        if (ip.type !== "data") {
          continue;
        }
        if (!Array.isArray(ip.data)) {
          continue;
        }
        arrays.push(ip.data);
      }
    }
    if (!arrays.length) {
      output.sendDone({ out: [] });
      return;
    }
    output.sendDone({ out: zip(arrays) });
  });

  return c;
}
