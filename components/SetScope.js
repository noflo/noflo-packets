import { Component, IP } from "@noflo/noflo";

/**
 * Sets the scope of the outgoing IP to the value of the `scope` control.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Set scope for the IP packet",
    icon: "indent",
    inPorts: {
      in: { datatype: "object", required: true },
      scope: { datatype: "string", control: true, required: true },
    },
    outPorts: {
      out: { datatype: "object", scoped: true },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in", "scope")) {
      return;
    }
    const [data, scope] = input.getData("in", "scope");
    output.sendDone({ out: new IP("data", data, { scope }) });
  });

  return c;
}
