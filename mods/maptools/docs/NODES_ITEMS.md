# List of nodes/items

To use an item, make sure you have the `give` privilege, then use
`/give <player> <item code> [amount]` or `/giveme <item code> [amount]`.

**Tip:** To give yourself a large amount of items quickly (65535 as of writing),
use `-1` as the amount.

## Nodes

:warning: denotes an unpointable, unbreakable block; be very careful with them,
as they cannot be removed by hand (they can only be removed with
[WorldEdit](https://github.com/Uberi/Minetest-WorldEdit) or similar).

| Item code               | Description                                                                                                                                                            |
| ----------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `maptools:{block}_u`    | Unbreakable, non-flammable, non-falling, non-decaying blocks. Most common default blocks have an unbreakable form available (`maptools:stone_u`, `maptools:wood_u`, …) |
| `maptools:full_grass`   | Unbreakable block with the grass texture on all sides.                                                                                                                 |
| `maptools:player_clip`  | :warning: Invisible, non-pointable block that blocks players and entities.                                                                                             |
| `maptools:full_clip`    | Invisible, pointable block that blocks players and entities. Also available as a thin face (`maptools:full_clip_face`).                                                |
| `maptools:smoke`        | Some smoke. Decreases visibility, but doesn't damage players or entities).                                                                                             |
| `maptools:no_build`     | :warning: Very basic building prevention.                                                                                                                              |
| `maptools:no_interact`  | Prevents interacting through the block (opening chests, furnaces, attacking entities, …), but can still be walked through.                                             |
| `maptools:damage_{1…5}` | :warning: Damaging blocks which damage players by 1 to 5 HP per second.                                                                                                |
| `maptools:kill`         | :warning: Instant kill blocks (damages players by 20 HP per second).                                                                                                   |
| `maptools:drowning`     | :warning: Simulates drowning in water.                                                                                                                                 |
| `maptools:light_block`  | :warning: Invisible non-solid block, prevents light from passing through.                                                                                              |
| `maptools:lightbulb`   | :warning: Invisible non-solid block, emitting the maximum amount of light.                                                                                              |

## Items

| Item code                        | Description                                                                                                                                       |
| -------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| `maptools:admin_pick`            | A bright magenta pickaxe with infinite durability, digs everything including unbreakable blocks instantly. No drops are given when digging nodes. |
| `maptools:admin_pick_with_drops` | Same as the admin pickaxe, but drops are given when digging nodes.                                                                                |
| `maptools:infinite_fuel`         | Fuel lasting for a near-infinite time (about 50 real-life years).                                                                                 |
| `maptools:super_apple`           | A yellow apple which heals the player by 20 HP when used.                                                                                         |
| `maptools:copper_coin`           | Decorative item (can be used in mini-games).                                                                                                      |
| `maptools:silver_coin`           | Decorative item (can be used in mini-games).                                                                                                      |
| `maptools:gold_coin`             | Decorative item (can be used in mini-games).                                                                                                      |
