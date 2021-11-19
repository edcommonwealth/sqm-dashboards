#!/usr/bin/env sh

set -eux

git rev-parse --show-toplevel

APP=$1
TIMESTAMP=$(date +%s)
DUMP_FILENAME=$APP.$TIMESTAMP.dump

## Uncomment this if you want the latest data
# heroku pg:backups:capture
heroku pg:backups:download --app=mciea-$APP --output=$DUMP_FILENAME

pg_restore --clean --no-acl --no-owner --dbname=mciea_development $DUMP_FILENAME

bundle exec rails db:environment:set RAILS_ENV=development

# clean up after ourselves; comment this out if you want to hold on to dump file
rm $DUMP_FILENAME
