ARG ENGINE_VERSION=5.5.0
FROM registry.gitlab.com/minetest/minetest/server:${ENGINE_VERSION}

USER root

COPY ./entrypoint.sh /entrypoint.sh
COPY ./stages/ /stages/

RUN apk add git &&\
    mkdir -p /root/.minetest/worlds/world/worldmods/ &&\
    git clone https://github.com/BuckarooBanzay/mtt /root/.minetest/worlds/world/worldmods/mtt


ENTRYPOINT /entrypoint.sh