# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- [The Admin Pickaxe can now dig More Ores' mithril blocks with client-side prediction (thanks to `maxlevel` being increased from 3 to 5).](https://github.com/minetest-mods/maptools/pull/30)

## [2.2.0] - 2021-06-28

### Changed

- [Disabled crafting recipes for coins by default.](https://github.com/minetest-mods/maptools/pull/29)
  - They can be enabled again by setting `maptools.enable_coin_crafting = true`
    in `minetest.conf`.
- Map Tools nodes can no longer be exploded by TNT.
- Switched from Travis CI to GitHub Actions for continuous integration.

## [2.1.0] - 2020-06-08

### Changed

- 10 coins of each type can now be crafted using 2 ingots (bronze, silver or gold).
  - Silver coins require [More Ores](https://github.com/minetest-mods/moreores)
    to be crafted, since minetest_game doesn't have silver ingots.
- Coins are now displayed in the creative inventory.
- Moved translations from intllib to Minetest's built-in localization system.
  - This allows translations to show up independently of the server's language.

## [2.0.0] - 2019-11-25

### Changed

- The minimum supported Minetest version is now 5.0.0.
- Map Tools nodes/items can no longer be dropped to prevent them from falling
  into bad hands.

### Fixed

- The inventory images of `no_interact`, `no_build`, `ignore_like_no_clip`
  and `ignore_like_no_point` now use textures that are available in
  Minetest Game 5.0.0.

## [1.1.0] - 2019-03-23

### Changed

- Increased the range of the Admin Pickaxe from 12 to 20 nodes.
- Updated intllib support to avoid using deprecated functions.

## 1.0.0 - 2017-02-19

- Initial versioned release.

[Unreleased]: https://github.com/minetest-mods/maptools/compare/v2.2.0...HEAD
[2.2.0]: https://github.com/minetest-mods/maptools/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/minetest-mods/maptools/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/minetest-mods/maptools/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/minetest-mods/maptools/compare/v1.0.0...v1.1.0
