#!/bin/bash

docker build --pull . -f Dockerfile.alpine-ruby24 -t ochorocho/gitlab-mirror-pull:alpine-ruby-2.4 && \
docker build --pull . -f Dockerfile.alpine-ruby25 -t ochorocho/gitlab-mirror-pull:alpine-ruby-2.5
