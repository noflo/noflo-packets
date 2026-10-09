import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as noflo from "@noflo/noflo";
import { getComponent as getCounter } from "../components/Counter.js";
import { getComponent as getCountPackets } from "../components/CountPackets.js";
import { getComponent as getDefaults } from "../components/Defaults.js";
import { getComponent as getFilterByPosition } from "../components/FilterByPosition.js";
import { getComponent as getFlatten } from "../components/Flatten.js";
import { getComponent as getGroupByPacket } from "../components/GroupByPacket.js";
import { getComponent as getSendWith } from "../components/SendWith.js";
import { getComponent as getStepSequencer } from "../components/StepSequencer.js";
import { getComponent as getZip } from "../components/Zip.js";
import { collect, render, sendGrouped, waitStream } from "./helpers.js";

describe("CountPackets component", () => {
  it("counts data IPs per group and mirrors brackets on count", () => {
    const c = getCountPackets();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    const countSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    c.outPorts.count.attach(countSocket);
    const outIps = collect(outSocket);
    const countIps = collect(countSocket);
    inSocket.post(new noflo.IP("openBracket", ""));
    inSocket.post(new noflo.IP("openBracket", ""));
    inSocket.post(new noflo.IP("data", "a"));
    inSocket.post(new noflo.IP("data", "b"));
    inSocket.post(new noflo.IP("closeBracket", ""));
    inSocket.post(new noflo.IP("openBracket", ""));
    inSocket.post(new noflo.IP("data", "c"));
    inSocket.post(new noflo.IP("closeBracket", ""));
    inSocket.post(new noflo.IP("data", "d"));
    inSocket.post(new noflo.IP("closeBracket", ""));
    assert.deepEqual(render(outIps), [
      "< ",
      "< ",
      'DATA "a"',
      'DATA "b"',
      ">",
      "< ",
      'DATA "c"',
      ">",
      'DATA "d"',
      ">",
    ]);
    assert.deepEqual(render(countIps), [
      "< ",
      "< ",
      "DATA 2",
      ">",
      "< ",
      "DATA 1",
      ">",
      "DATA 1",
      ">",
    ]);
    c.tearDown?.();
  });

  it("counts unbracketed data IPs one at a time", () => {
    const c = getCountPackets();
    const inSocket = noflo.internalSocket.createSocket();
    const countSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.count.attach(countSocket);
    const countIps = collect(countSocket);
    inSocket.post(new noflo.IP("data", "a"));
    inSocket.post(new noflo.IP("data", "b"));
    inSocket.post(new noflo.IP("data", "c"));
    assert.deepEqual(
      countIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [1, 1, 1],
    );
    c.tearDown?.();
  });
});

describe("Counter component", () => {
  /** @returns {{ c: import("@noflo/noflo").Component, inSocket: import("@noflo/noflo").internalSocket.InternalSocket, immediateSocket: import("@noflo/noflo").internalSocket.InternalSocket | null, countIps: import("@noflo/noflo").IP[], outIps: import("@noflo/noflo").IP[] }} */
  const build = (attachImmediate = false) => {
    const c = getCounter();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    const countSocket = noflo.internalSocket.createSocket();
    /** @type {import("@noflo/noflo").internalSocket.InternalSocket|null} */
    let immediateSocket = null;
    c.inPorts.in.attach(inSocket);
    if (attachImmediate) {
      immediateSocket = noflo.internalSocket.createSocket();
      c.inPorts.immediate.attach(immediateSocket);
    }
    c.outPorts.out.attach(outSocket);
    c.outPorts.count.attach(countSocket);
    return {
      c,
      inSocket,
      immediateSocket,
      outIps: collect(outSocket),
      countIps: collect(countSocket),
    };
  };

  it("counts each unbracketed packet and resets", () => {
    const { c, inSocket, countIps } = build();
    inSocket.post(new noflo.IP("data", "a"));
    inSocket.post(new noflo.IP("data", "b"));
    inSocket.post(new noflo.IP("data", "c"));
    assert.deepEqual(
      countIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [1, 1, 1],
    );
    c.tearDown?.();
  });

  it("sends one count per grouped stream without immediate", () => {
    const { c, inSocket, countIps } = build();
    sendGrouped(inSocket, ["g1"], ["a", "b", "c"]);
    assert.deepEqual(
      countIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [3],
    );
    c.tearDown?.();
  });

  it("sends the running count immediately when requested", () => {
    const { c, inSocket, immediateSocket, countIps } = build(true);
    immediateSocket?.post(new noflo.IP("data", true));
    sendGrouped(inSocket, ["g1"], ["a", "b"]);
    // The stream close re-sends the final count before resetting
    assert.deepEqual(
      countIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [1, 2, 2],
    );
    c.tearDown?.();
  });

  it("reset zeroes the count", () => {
    const { c, inSocket, countIps } = build();
    inSocket.post(new noflo.IP("data", "a"));
    inSocket.post(new noflo.IP("data", null));
    assert.deepEqual(
      countIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [1, 1],
    );
    c.tearDown?.();
  });
});

describe("Defaults component", () => {
  it("fills missing stream positions with defaults", () => {
    const c = getDefaults();
    const inSocket = noflo.internalSocket.createSocket();
    const defaultSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.default.attach(defaultSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    defaultSocket.post(new noflo.IP("data", "default1"));
    defaultSocket.post(new noflo.IP("data", "default2"));
    inSocket.post(new noflo.IP("openBracket", "g"));
    inSocket.post(new noflo.IP("data", "first"));
    inSocket.post(new noflo.IP("closeBracket", "g"));
    assert.deepEqual(render(outIps), [
      "< g",
      'DATA "first"',
      'DATA "default2"',
      ">",
    ]);
    c.tearDown?.();
  });

  it("fills an unbracketed null with the first default", () => {
    const c = getDefaults();
    const inSocket = noflo.internalSocket.createSocket();
    const defaultSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.default.attach(defaultSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    defaultSocket.post(new noflo.IP("data", "the default"));
    inSocket.post(new noflo.IP("data", null));
    assert.deepEqual(render(outIps), ['DATA "the default"']);
    c.tearDown?.();
  });
});

describe("Flatten component", () => {
  it("flattens nested groups to the top level", () => {
    const c = getFlatten();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    inSocket.post(new noflo.IP("openBracket", "a"));
    inSocket.post(new noflo.IP("data", "1"));
    inSocket.post(new noflo.IP("openBracket", "b"));
    inSocket.post(new noflo.IP("data", "2"));
    inSocket.post(new noflo.IP("closeBracket", "b"));
    inSocket.post(new noflo.IP("data", "3"));
    inSocket.post(new noflo.IP("closeBracket", "a"));
    assert.deepEqual(render(outIps), [
      "< a",
      'DATA "1"',
      ">",
      "< b",
      'DATA "2"',
      ">",
      'DATA "3"',
    ]);
    c.tearDown?.();
  });
});

describe("FilterByPosition component", () => {
  it("keeps only positions with a true filter", () => {
    const c = getFilterByPosition();
    const inSocket = noflo.internalSocket.createSocket();
    const filterSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.filter.attach(filterSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    filterSocket.post(new noflo.IP("data", true));
    filterSocket.post(new noflo.IP("data", false));
    filterSocket.post(new noflo.IP("data", true));
    sendGrouped(inSocket, ["g"], ["a", "b", "c", "d"]);
    assert.deepEqual(render(outIps), ["< g", 'DATA "a"', 'DATA "c"', ">"]);
    c.tearDown?.();
  });
});

describe("GroupByPacket component", () => {
  it("surrounds each data packet with a position bracket", () => {
    const c = getGroupByPacket();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    // The position persists across consecutive unbracketed packets
    // (1.x counted across the whole connection stream)
    inSocket.post(new noflo.IP("data", "a"));
    inSocket.post(new noflo.IP("data", "b"));
    assert.deepEqual(render(outIps), [
      "< 0",
      'DATA "a"',
      ">",
      "< 1",
      'DATA "b"',
      ">",
    ]);
    c.tearDown?.();
  });

  it("restarts positions within each incoming group", () => {
    const c = getGroupByPacket();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    sendGrouped(inSocket, ["g"], ["a", "b"]);
    assert.deepEqual(render(outIps), [
      "< g",
      "< 0",
      'DATA "a"',
      ">",
      "< 1",
      'DATA "b"',
      ">",
      ">",
    ]);
    c.tearDown?.();
  });
});

describe("SendWith component", () => {
  it("appends the with packets after the last data IP", () => {
    const c = getSendWith();
    const inSocket = noflo.internalSocket.createSocket();
    const withSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.with.attach(withSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    withSocket.post(new noflo.IP("data", "footer"));
    sendGrouped(inSocket, ["g"], ["a", "b"]);
    assert.deepEqual(render(outIps), [
      "< g",
      'DATA "a"',
      'DATA "b"',
      'DATA "footer"',
      ">",
    ]);
    c.tearDown?.();
  });
});

describe("Zip component", () => {
  it("zips arrays across connections, truncating to the shortest", async () => {
    const c = getZip();
    const s0 = noflo.internalSocket.createSocket();
    const s1 = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(s0, 0);
    c.inPorts.in.attach(s1, 1);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    s0.post(new noflo.IP("data", ["a", "b", "c"]));
    s1.post(new noflo.IP("data", [1, 2]));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [
        [
          ["a", 1],
          ["b", 2],
        ],
      ],
    );
    c.tearDown?.();
  });

  it("ignores non-array IPs and zips the rest", async () => {
    const c = getZip();
    const s0 = noflo.internalSocket.createSocket();
    const s1 = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(s0, 0);
    c.inPorts.in.attach(s1, 1);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    s0.post(new noflo.IP("data", "not an array"));
    s1.post(new noflo.IP("data", ["a"]));
    await waitStream(outIps, (ips) => ips.length > 0);
    // The non-array IP is skipped; the remaining single array zips into
    // one row
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [[["a"]]],
    );
    c.tearDown?.();
  });
});

describe("StepSequencer component", () => {
  it("sends values at their timestamp offsets", async () => {
    const c = getStepSequencer();
    const patternSocket = noflo.internalSocket.createSocket();
    const valueSocket = noflo.internalSocket.createSocket();
    c.inPorts.pattern.attach(patternSocket);
    c.outPorts.value.attach(valueSocket);
    const valueIps = collect(valueSocket);
    patternSocket.post(new noflo.IP("data", "10,a,60,b"));
    await waitStream(
      valueIps,
      (ips) => ips.filter((ip) => ip.type === "data").length === 2,
    );
    assert.deepEqual(
      valueIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      ["a", "b"],
    );
    c.tearDown?.();
  });

  it("does nothing for a pattern with fewer than two entries", async () => {
    const c = getStepSequencer();
    const patternSocket = noflo.internalSocket.createSocket();
    const valueSocket = noflo.internalSocket.createSocket();
    c.inPorts.pattern.attach(patternSocket);
    c.outPorts.value.attach(valueSocket);
    const valueIps = collect(valueSocket);
    patternSocket.post(new noflo.IP("data", "10"));
    await new Promise((resolve) => setTimeout(resolve, 60));
    assert.deepEqual(
      valueIps.filter((ip) => ip.type === "data"),
      [],
    );
    c.tearDown?.();
  });

  it("replaces a running pattern when a new one arrives", async () => {
    const c = getStepSequencer();
    const patternSocket = noflo.internalSocket.createSocket();
    const valueSocket = noflo.internalSocket.createSocket();
    c.inPorts.pattern.attach(patternSocket);
    c.outPorts.value.attach(valueSocket);
    const valueIps = collect(valueSocket);
    patternSocket.post(new noflo.IP("data", "5000,first"));
    await new Promise((resolve) => setTimeout(resolve, 30));
    patternSocket.post(new noflo.IP("data", "10,second"));
    await waitStream(
      valueIps,
      (ips) => ips.filter((ip) => ip.type === "data").length === 1,
    );
    assert.deepEqual(
      valueIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      ["second"],
    );
    c.tearDown?.();
  });
});
