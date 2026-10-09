import { Component, IP } from "@noflo/noflo";

/**
 * Copies the scope of the incoming packet into a property of the payload
 * and emits the result unscoped. The property name comes from the
 * `property` control (default `scope`).
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Set the scope of the received packet into a property inside the payload",
    icon: "indent",
    inPorts: {
      in: { datatype: "object", scoped: true, required: true },
      property: {
        datatype: "string",
        control: true,
        default: "scope",
        scoped: false,
      },
    },
    outPorts: {
      out: { datatype: "object", scoped: false },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    if (input.attached("property").length && !input.hasData("property")) {
      return;
    }
    let property = "scope";
    if (input.hasData("property")) {
      property = input.getData("property");
    }
    const data = input.getData("in");
    data[property] = input.scope;
    output.sendDone({ out: new IP("data", data) });
  });

  return c;
}
