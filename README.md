# @noflo/packets

Packet Utilities for [NoFlo](http://noflojs.org/)

This package provides utility components for working with NoFlo
information packets: counting, filtering, zipping, scoping, and
sequencing.

## Usage

Install the package:

    npm install @noflo/packets

The components are then available under the `packets/` namespace, for
example `packets/CountPackets` or `packets/SetScope`.

Components include:

- `CountPackets`, `Counter` — count data packets per stream
- `Compact`, `Defaults`, `LastPacket`, `Range`, `UniquePacket` — filter
  and reduce streams
- `FilterByPosition`, `FilterByValue`, `FilterPacket`, `FilterPackets`,
  `Map`, `Replace` — filter and transform packet values
- `GetScope`, `SetScope`, `ScopeToObject`, `ScopeFromObject` — manage
  packet scopes
- `Flatten`, `GroupByPacket`, `SendWith`, `Zip`, `Unzip` — restructure
  streams
- `StepSequencer` — timestamp-based value sequencing

The `graphs/First` graph forwards only the first packet of a stream.
