# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [2.0.0-alpha.1] - 2026-10-09

### Added

- The package is renamed to `@noflo/packets`; graph component identifiers are unaffected and keep resolving under the `packets/` namespace

### Changed

- All 23 components are converted from CoffeeScript to modern JavaScript ES modules for NoFlo 2.x (esm-only), with TypeScript-checked sources and Biome formatting
- Components follow the 2.x Process API contract: preconditions are checked with `has`/`hasData`/`hasStream` before any `get`/`getData` call, and per-scope state is kept in Maps cleared in async `tearDown`
- The `underscore` dependency is dropped: `_.last`/`_.isEmpty`/`_.isObject`/`_.any` are replaced by language built-ins, and `_.zip` is inlined with the same truncate-to-shortest semantics
- `Range`, `FilterByPosition`, and `GroupByPacket` keep their position counters in per-scope state that persists across consecutive unbracketed packets and resets at brackets — under 2.x each unbracketed data IP would otherwise be its own complete stream, breaking the 1.x counting behavior across bursts
- The `graphs/First` graph's port exports are renamed to lowercase (`in`, `out`, `length` edge target) per 2.x port-name validation
- `CountPackets` sends a clone of each bracket IP to its `count` port instead of sharing the same IP instance between two out-ports

### Fixed

- Test suite rebuilt on `@noflo/fbp-spec-runner` (fbp-spec YAML cases) and `node:test` (27 tests including the `graphs/First` subgraph), replacing the Mocha CoffeeScript suite
