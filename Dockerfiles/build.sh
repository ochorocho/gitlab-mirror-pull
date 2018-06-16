#!/bin/bash

docker build --pull . -f Dockerfile.ruby23 -t ochorocho/gitlab-mirror-pull:ruby-2.3 && \
docker build --pull . -f Dockerfile.alpine-ruby24 -t ochorocho/gitlab-mirror-pull:alpine-ruby-2.4 && \
docker build --pull . -f Dockerfile.ruby24 -t ochorocho/gitlab-mirror-pull:ruby-2.4
