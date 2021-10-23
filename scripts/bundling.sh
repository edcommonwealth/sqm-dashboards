#!/usr/bin/env sh

set -eux

yarn sass ./app/assets/stylesheets/application.bootstrap.scss ./app/assets/builds/application.css --no-source-map --load-path=node_modules --watch & yarn sass ./app/assets/stylesheets/sqm_application.scss ./app/assets/builds/sqm_application.css --no-source-map --load-path=node_modules --watch & npx sass ./app/assets/stylesheets/welcome.scss ./app/assets/builds/welcome.css --no-source-map --load-path=node_modules --watch & yarn build --watch 
