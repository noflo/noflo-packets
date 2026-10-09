import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as noflo from "@noflo/noflo";

import { getComponent as getGetScope } from "../components/GetScope.js";
import { getComponent as getScopeFromObject } from "../components/ScopeFromObject.js";
import { getComponent as getScopeToObject } from "../components/ScopeToObject.js";
import { getComponent as getSetScope } from "../components/SetScope.js";
import { collect, waitStream } from "./helpers.js";

describe("GetScope component", () => {
  it("forwards the scope and the data", () => {
    const c = getGetScope();
    const inSocket = noflo.internalSocket.createSocket();
    const scopeSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.scope.attach(scopeSocket);
    c.outPorts.out.attach(outSocket);
    const scopeIps = collect(scopeSocket);
    const outIps = collect(outSocket);
    inSocket.post(new noflo.IP("data", { hello: "world" }, { scope: "foo" }));
    assert.deepEqual(
      scopeIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      ["foo"],
    );
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [{ hello: "world" }],
    );
    c.tearDown?.();
  });

  it("sends a null scope for unscoped packets", () => {
    const c = getGetScope();
    const inSocket = noflo.internalSocket.createSocket();
    const scopeSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.scope.attach(scopeSocket);
    const scopeIps = collect(scopeSocket);
    inSocket.post(new noflo.IP("data", { a: 1 }));
    assert.deepEqual(
      scopeIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [null],
    );
    c.tearDown?.();
  });
});

describe("SetScope component", () => {
  it("sets the outgoing scope from the control", () => {
    const c = getSetScope();
    const inSocket = noflo.internalSocket.createSocket();
    const scopeSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.scope.attach(scopeSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    scopeSocket.post(new noflo.IP("data", "myscope"));
    inSocket.post(new noflo.IP("data", { a: 1 }));
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.scope),
      ["myscope"],
    );
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [{ a: 1 }],
    );
    c.tearDown?.();
  });
});

describe("ScopeToObject component", () => {
  it("copies the scope into a payload property and unscopes", () => {
    const c = getScopeToObject();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    inSocket.post(new noflo.IP("data", { a: 1 }, { scope: "client1" }));
    const ip = /** @type {import("@noflo/noflo").IP} */ (
      outIps.find((candidate) => candidate.type === "data")
    );
    assert.deepEqual(ip.data, { a: 1, scope: "client1" });
    assert.equal(ip.scope, null);
    c.tearDown?.();
  });

  it("uses a custom property name", () => {
    const c = getScopeToObject();
    const inSocket = noflo.internalSocket.createSocket();
    const propertySocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.property.attach(propertySocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    propertySocket.post(new noflo.IP("data", "origin"));
    inSocket.post(new noflo.IP("data", { a: 1 }, { scope: "client2" }));
    const ip = /** @type {import("@noflo/noflo").IP} */ (
      outIps.find((candidate) => candidate.type === "data")
    );
    assert.deepEqual(ip.data, { a: 1, origin: "client2" });
    c.tearDown?.();
  });
});

describe("ScopeFromObject component", () => {
  it("reads the scope from the payload and scopes the output", async () => {
    const c = getScopeFromObject();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    inSocket.post(new noflo.IP("data", { a: 1, scope: "client3" }));
    await waitStream(outIps, (ips) => ips.length > 0);
    const ip = /** @type {import("@noflo/noflo").IP} */ (
      outIps.find((candidate) => candidate.type === "data")
    );
    assert.deepEqual(ip.data, { a: 1 });
    assert.equal(ip.scope, "client3");
    c.tearDown?.();
  });
});
