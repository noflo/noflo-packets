import { Component } from "@noflo/noflo";

/**
 * Sends only the last data IP of a stream, dropping everything else.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Send only the last packet of a stream",
    icon: "caret-square-o-down",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  c.process((input, output) => {
    if (!input.hasStream("in")) {
      return;
    }
    const packets = /** @type {import("@noflo/noflo").IP[]} */ (
      input.getStream("in")
    );
    const datas = packets.filter((ip) => ip.type === "data");
    if (!datas.length) {
      output.done();
      return;
    }
    output.sendDone({ out: datas[datas.length - 1] });
  });

  return c;
}
