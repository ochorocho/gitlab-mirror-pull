#!/bin/bash

docker build --pull . -f Dockerfile.ruby23 -t ochorocho/gitlab-mirror-pull:ruby23 && \
docker build --pull . -f Dockerfile.ruby24 -t ochorocho/gitlab-mirror-pull:ruby24
