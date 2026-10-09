import { Component } from "@noflo/noflo";

/**
 * Copies the scope of the incoming IP onto a `scope` port, forwarding
 * the data unchanged.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Get scope of the IP packet",
    icon: "outdent",
    inPorts: {
      in: { datatype: "object", scoped: true, required: true },
    },
    outPorts: {
      out: { datatype: "object" },
      scope: { datatype: "string" },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    output.sendDone({ scope: input.scope, out: data });
  });

  return c;
}
