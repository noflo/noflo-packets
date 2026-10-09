import { Component } from "@noflo/noflo";

/**
 * Filters packets against a list of regular expressions accumulated on
 * the `regexp` port. Matching packets go to `out`, non-matching to
 * `missed`; everything is also echoed to `passthru`.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Filter packets matching some RegExp strings",
    icon: "filter",
    inPorts: {
      in: { datatype: "string", required: true },
      regexp: { datatype: "string" },
    },
    outPorts: {
      out: { datatype: "string" },
      missed: { datatype: "string" },
      passthru: { datatype: "string" },
    },
  });

  /** @type {RegExp[]} */
  const regexps = [];
  c.tearDown = async () => {
    regexps.length = 0;
  };

  c.process((input, output) => {
    if (input.hasData("regexp")) {
      let reg = input.getData("regexp");
      if (typeof reg === "string") {
        reg = new RegExp(reg);
      }
      regexps.push(reg);
      output.done();
      return;
    }

    if (!input.hasData("in")) {
      return;
    }
    const data = input.getData("in");
    if (regexps.some((regexp) => data.match(regexp))) {
      output.sendDone({ out: data, passthru: data });
      return;
    }
    output.sendDone({ missed: data, passthru: data });
  });

  return c;
}
