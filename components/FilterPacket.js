import { Component } from "@noflo/noflo";

/**
 * Filters string packets with a regular expression from the `regexp`
 * control. Without a regexp everything passes to `out`.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Filter packets with regular expression",
    icon: "filter",
    inPorts: {
      in: { datatype: "string", required: true },
      regexp: { datatype: "string", control: true },
    },
    outPorts: {
      out: { datatype: "string" },
      missed: { datatype: "string" },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    if (!input.hasData("regexp")) {
      // No regexp provided, just send data
      output.sendDone({ out: data });
      return;
    }
    let regexp = input.getData("regexp");
    if (typeof regexp === "string") {
      regexp = new RegExp(regexp);
    }
    if (regexp.exec(data)) {
      output.sendDone({ out: data });
      return;
    }
    output.sendDone({ missed: data });
  });

  return c;
}
