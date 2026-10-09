import { Component, IP } from "@noflo/noflo";

/**
 * Reads the scope from a property of the incoming payload, deletes the
 * property, and sets it as the outgoing IP scope. The property name comes
 * from the `property` control (default `scope`).
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Read the scope from received packet and set to IP scope",
    icon: "outdent",
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
      out: { datatype: "object", scoped: true },
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
    const scope = data[property];
    delete data[property];
    output.sendDone({ out: new IP("data", data, { scope }) });
  });

  return c;
}
