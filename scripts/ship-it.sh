#!/usr/bin/env sh

set -eux

git rev-parse --show-toplevel

bundle exec rake parallel:spec && yarn test && git push
