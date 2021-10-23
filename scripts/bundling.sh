#!/usr/bin/env sh

set -eux

yarn build --watch & yarn build:css --watch 
