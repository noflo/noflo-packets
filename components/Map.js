import { Component } from "@noflo/noflo";

/**
 * Replaces packets through a map (an object, or a comma-separated
 * `key:value` string). Keys not in the map return the `def` control
 * value, or the input itself when no default is set.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Replace packets through a map. Data that is not in the map is replace with the default.",
    icon: "table",
    inPorts: {
      data: {
        datatype: "all",
        description: "Data to be used as a key.",
        required: true,
      },
      map: {
        datatype: "all",
        description: "A map with replacement values",
        control: true,
        required: true,
      },
      def: {
        datatype: "all",
        description:
          "A default value to return if the key is not in the map. If unset return the input.",
        control: true,
      },
    },
    outPorts: {
      data: {
        datatype: "all",
        description: "The content of map[data].",
      },
    },
  });

  /**
   * @param {unknown} orig
   * @returns {Record<string, unknown>}
   */
  const prepareMap = (orig) => {
    if (typeof orig === "object") {
      return /** @type {Record<string, unknown>} */ (orig);
    }
    /** @type {Record<string, unknown>} */
    const map = {};
    for (const mapPart of /** @type {string} */ (orig).split(",")) {
      const mapEntry = mapPart.split(":");
      if (mapEntry[0] && mapEntry[1]) {
        map[mapEntry[0].trim()] = mapEntry[1].trim();
      }
    }
    return map;
  };

  c.process((input, output) => {
    if (!input.hasData("map", "data")) {
      return;
    }
    const map = prepareMap(input.getData("map"));
    const data = input.getData("data");
    if (data in map) {
      output.sendDone({ data: map[data] });
      return;
    }
    if (input.hasData("def")) {
      const def = input.getData("def");
      output.sendDone({ data: def });
      return;
    }
    output.sendDone({ data });
  });

  return c;
}
