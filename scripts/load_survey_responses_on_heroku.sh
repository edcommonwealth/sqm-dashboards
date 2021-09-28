#!/usr/bin/env sh

set -eux

git rev-parse --show-toplevel

APP=$1

heroku login

heroku run:detached -a mciea-$APP bundle exec rake data:load_survey_responses
