#!/bin/sh

set -e

echo "Preparing stage1: smoketests"
cp -R /stages/stage1 /root/.minetest/worlds/world/worldmods/stage1

cat << EOF > /minetest.conf
default_game = minetest_game
mg_name = v7
mtt_enable = true
mtt_filter = modgen
EOF

echo "Executing stage1"
minetestserver --config /minetest.conf

echo "Cleanup"
rm -rf /root/.minetest/worlds/world/worldmods/stage1

echo "Preparing stage2: mapgen and export"
cp -R /stages/stage2 /root/.minetest/worlds/world/worldmods/stage2

cat << EOF > /minetest.conf
default_game = minetest_game
mg_name = v7
EOF

echo "Executing stage2"
minetestserver --config /minetest.conf

test -d /root/.minetest/worlds/world/modgen_mod_export
cat /root/.minetest/worlds/world/modgen_mod_export/manifest.json

echo "Cleanup"
rm -rf /root/.minetest/worlds/world/worldmods/stage2
rm /root/.minetest/worlds/world/map.sqlite

echo "Preparing stage3: import"
cp -R /stages/stage3 /root/.minetest/worlds/world/worldmods/stage3
mv /root/.minetest/worlds/world/modgen_mod_export /root/.minetest/worlds/world/worldmods

cat << EOF > /minetest.conf
default_game = minetest_game
mg_name = singlenode
EOF

echo "Executing stage3"
minetestserver --config /minetest.conf