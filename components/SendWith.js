import { Component } from "@noflo/noflo";

/**
 * Always sends the packets accumulated on the `with` port after the last
 * data IP of each incoming stream. Per scope.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Always send the specified packets with incoming packets.",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
      with: { datatype: "all" },
    },
    outPorts: {
      out: { datatype: "all" },
    },
  });

  /** @type {Map<string, unknown[]>} */
  const withPackets = new Map();
  c.tearDown = async () => {
    withPackets.clear();
  };

  c.process((input, output) => {
    const key = input.scope ?? "null";
    if (input.hasData("with")) {
      let list = withPackets.get(key);
      if (!list) {
        list = [];
        withPackets.set(key, list);
      }
      list.push(input.getData("with"));
      output.done();
      return;
    }
    if (!input.hasStream("in")) {
      return;
    }
    const packets = /** @type {import("@noflo/noflo").IP[]} */ (
      input.getStream("in")
    );
    const datas = packets.filter((ip) => ip.type === "data");
    const stored = withPackets.get(key);
    for (const ip of packets) {
      output.send({ out: ip });
      if (ip !== datas[datas.length - 1]) {
        continue;
      }
      if (!stored) {
        continue;
      }
      // Send 'withs' after last data IP
      for (const packet of stored) {
        output.send({ out: packet });
      }
    }
    output.done();
  });

  return c;
}
