import { Component } from "@noflo/noflo";

/**
 * A timestamp-value pattern sequencer: takes a comma-separated list of
 * `timestamp,value` pairs (timestamps in ms) and sends each value on the
 * `value` port at its timestamp offset from the previous entry.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "A timestamp-value pattern sequencer",
    icon: "bar-chart",
    forwardBrackets: {},
    inPorts: {
      pattern: {
        datatype: "string",
        description:
          "Comma separated timestamp-value pairs. Timestamps are in ms.",
        required: true,
      },
    },
    outPorts: {
      value: {
        datatype: "string",
        description: "Current value",
      },
    },
  });

  /**
   * @typedef {Object} SequenceContext
   * @property {ReturnType<typeof setTimeout>} [timeout]
   */

  /** @type {Map<string, { deactivate(): void }>} */
  const timers = new Map();
  c.tearDown = async () => {
    for (const context of timers.values()) {
      const sequenceContext = /** @type {SequenceContext} */ (
        /** @type {unknown} */ (context)
      );
      if (sequenceContext.timeout) {
        clearTimeout(sequenceContext.timeout);
      }
      context.deactivate();
    }
    timers.clear();
  };

  c.process((input, output, context) => {
    if (!input.hasData("pattern")) {
      return;
    }

    const key = input.scope ?? "null";
    const previous = timers.get(key);
    if (previous) {
      const previousSequence = /** @type {SequenceContext} */ (
        /** @type {unknown} */ (previous)
      );
      if (previousSequence.timeout) {
        clearTimeout(previousSequence.timeout);
      }
      previous.deactivate();
    }

    let pattern = input.getData("pattern");
    if (typeof pattern === "string") {
      pattern = pattern.split(",");
    }
    if (!pattern.length || pattern.length < 2) {
      output.done();
      return;
    }
    // TODO: validate ts to grow monolithically
    let ix = 0;
    let lastTs = 0;
    /**
     * @returns {void}
     */
    const sendNext = () => {
      lastTs = Number(pattern[ix]);
      const lastVal = pattern[ix + 1];
      output.send({ value: lastVal });
      ix += 2;
      if (ix < pattern.length) {
        sequenceContext.timeout = setTimeout(
          sendNext,
          Number(pattern[ix]) - lastTs,
        );
      } else {
        context.deactivate();
        timers.delete(key);
      }
    };
    const sequenceContext = /** @type {SequenceContext} */ (
      /** @type {unknown} */ (context)
    );
    sequenceContext.timeout = setTimeout(sendNext, Number(pattern[0]));
    timers.set(key, context);
  });

  return c;
}
