# Upgrading rails

## Guides

- Get a diff between two different versions of rails - <https://railsdiff.org/5.1.7/5.2.6>
- Official transition guide provided by rails - <https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2>

## Rails Upgrade

- change rails version number to 5.2
  - delete Gemfile.lock
  - `bundle install`
  - fix broken tests.
    - An SQL query asking for an average was returning a nil.  Check for nil in percent_for method
  - fix deprecation warnings
- change rails version number to 6.0.4.1
  - fix broken tests
    - change method name update_attributes to update
    - template error.  Change syntax for render method
  - fix deprecation warnings
- run rails migration - Creates new tables for ActiveStorage data
  - `bundle exec rake db:migrate`
- Attempt to generate credentials file for each environment
  - The syntax to generate this did not work
- Run the rake update task.
  - `bin/rails app:update`
- Update rails to 6.1 on the theory the syntax might have been added in a later version
  - fix broken tests
  - fix deprecation warnings
- Update system software on my machine
- Generate credentials file for each environment
- modify heroku mciea-beta app settings
  - change RAILS_ENV=production to RAILS_ENV=staging

## Javascript testing

- add esbuild gem 'jsbundling-rails'.  Unified installer for webpacker rollup and esbuild
  - `bin/bundle install`
  - `bin/rails javascript:install:esbuild
- clear the tmp directory to make sure asset compilation with esbuild does not complain about missing file templates
  - bundle exec rake tmp:clear
- move javascript files to new location
  - app/assets/javascript => app/javascript
  - I deleted the channels directory from app/assets/javascript but that caused problems with sprockets which expects the directory to exist even if it's empty.  Added the directory back, but git does not recognize empty directory as a change.  I added a .keep file in the channels directory so I could create a new git commit.
  - sprockets continues to bundle our scss files and images
- add missing dependencies to package.json.
  - turbolinks
  - actioncable
  - activestorage
  - ujs
- I did not wire up Action Cable
- `yarn install`
- Modify javascript files to implement exports
  - import those files into application.js
- Default jest environment does not allow for DOM interactions.  Change default test environment to jsdom
  - yarn jest --env=jsdom
- install node on heroku
  - heroku buildpacks:set heroku/ruby
  - heroku buildpacks:add --index 1 heroku/nodejs
- Fix dependabot alerts
  - upgrade puma
  - upgrade nokogiri
- Update README
- Generate binstubs for rspec

## Summary

- `bundle install`
- `bundle exec rake db:migrate`
- `yarn install`
- Optional: if you encounter problems `bundle exec rake tmp:clear`
- `yarn test`
- `yarn build --watch`
- `bin/rails s`

