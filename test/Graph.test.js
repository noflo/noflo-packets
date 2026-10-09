import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, it } from "node:test";
import { fileURLToPath } from "node:url";
import { parse } from "@noflo/fbp";
import { createNodeModulesRegistry } from "@noflo/loader-node";
import * as noflo from "@noflo/noflo";

const testDir = path.dirname(fileURLToPath(import.meta.url));
// The package root: discovery and the graph file live there
const baseDir = path.join(testDir, "..");

/** Loads the First graph as a subgraph component. */
const loadGraph = async () => {
  const source = readFileSync(
    path.join(baseDir, "graphs", "First.fbp"),
    "utf8",
  );
  const graphJson = parse(source);
  const graph = noflo.importFbpJson(graphJson);
  const registry = await createNodeModulesRegistry(baseDir);
  const loader = new noflo.ComponentLoader({ registry });
  loader.registerGraph("packets", "First", graph);
  const component = await loader.load("packets/First");
  // Starting the component starts the internal network and delivers its
  // IIPs (the length control). Data sent before start would race the
  // implicit data-triggered start and not see the IIPs.
  await component.start();
  return component;
};

/**
 * @param {import("@noflo/noflo").Component} component
 */
const wire = (component) => {
  const inSocket = noflo.internalSocket.createSocket();
  const outSocket = noflo.internalSocket.createSocket();
  component.inPorts.in.attach(inSocket);
  component.outPorts.out.attach(outSocket);
  return { inSocket, outSocket };
};

/**
 * @param {import("@noflo/noflo").IP[]} ips
 * @returns {string[]}
 */
const render = (ips) =>
  ips.map((ip) => {
    if (ip.type === "openBracket") {
      return "<";
    }
    if (ip.type === "closeBracket") {
      return ">";
    }
    return JSON.stringify(ip.data);
  });

describe("First graph", () => {
  it("sends a single IP through", async () => {
    const component = await loadGraph();
    const { inSocket, outSocket } = wire(component);
    /** @type {import("@noflo/noflo").IP[]} */
    const ips = [];
    outSocket.addEventListener(
      "ip",
      /** @param {CustomEvent} event */ (event) => {
        ips.push(event.detail);
      },
    );
    inSocket.post(new noflo.IP("data", "a"));
    await new Promise((resolve) => setTimeout(resolve, 100));
    assert.deepEqual(render(ips), ['"a"']);
  });

  it("sends a single IP in brackets through", async () => {
    const component = await loadGraph();
    const { inSocket, outSocket } = wire(component);
    /** @type {import("@noflo/noflo").IP[]} */
    const ips = [];
    outSocket.addEventListener(
      "ip",
      /** @param {CustomEvent} event */ (event) => {
        ips.push(event.detail);
      },
    );
    inSocket.post(new noflo.IP("openBracket", null));
    inSocket.post(new noflo.IP("data", "a"));
    inSocket.post(new noflo.IP("closeBracket", null));
    await new Promise((resolve) => setTimeout(resolve, 100));
    assert.deepEqual(render(ips), ["<", '"a"', ">"]);
  });

  it("sends only the first of multiple packets", async () => {
    const component = await loadGraph();
    const { inSocket, outSocket } = wire(component);
    /** @type {import("@noflo/noflo").IP[]} */
    const ips = [];
    outSocket.addEventListener(
      "ip",
      /** @param {CustomEvent} event */ (event) => {
        ips.push(event.detail);
      },
    );
    inSocket.post(new noflo.IP("data", "a"));
    inSocket.post(new noflo.IP("data", "b"));
    inSocket.post(new noflo.IP("data", "c"));
    await new Promise((resolve) => setTimeout(resolve, 100));
    assert.deepEqual(render(ips), ['"a"']);
  });
});
