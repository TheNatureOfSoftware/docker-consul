# About this repo

This is a Git repo of a multiarch (`armhf`, `arm64`,  `amd64`) docker build of [consul](https://registry.hub.docker.com/_/consul/).

This docker build tries to follow the [official image](https://docs.docker.com/docker-hub/official_repos/) and uses it's [docker-entrypoint.sh](https://github.com/hashicorp/docker-consul/blob/9fb940c32b6f46b0a77a640d7161054e00e97bbb/0.X/docker-entrypoint.sh).

The differences are:
* is based on [multiarch/alpine](https://hub.docker.com/r/multiarch/alpine/)
* uses [tini](https://github.com/krallin/tini) instead of `dumb-init`
* uses [su-exec](https://github.com/ncopa/su-exec) instead of `gosu`

