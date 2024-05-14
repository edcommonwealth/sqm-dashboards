source "https://rubygems.org"
ruby "3.3.1"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.1.3"
gem "sprockets-rails"

gem "pg"

# Use Puma as the app server
gem "puma", ">= 6.4.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# Use jquery as the JavaScript library
gem "jquery-rails"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
gem "redis", "~> 3.0"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem "nokogiri"

gem "bootsnap", require: false

gem "haml"

gem "friendly_id", "~> 5.1.0"

gem "newrelic_rpm"

gem "devise", git: "https://github.com/heartcombo/devise"

gem "omniauth"

gem "activerecord-import"

gem "jsbundling-rails"

gem "cssbundling-rails"

gem "turbo-rails"

gem "stimulus-rails"

gem "watir"

gem "bcrypt_pbkdf"
gem "ed25519"
gem "net-sftp"

gem "standard_deviation"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "parallel_tests"
  gem "rack-mini-profiler"
  gem "rspec-rails", "~> 6.0.3"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "brakeman"
  gem "bullet"
  gem "erb_lint", require: false
  gem "erblint-github"
  gem "guard"
  gem "guard-livereload", "~> 2.5", require: false
  gem "guard-rspec", require: false
  gem "listen", "~> 3.8.0"
  gem "nested_scaffold"
  gem "rack-livereload"
  # gem 'reek', require: false
  gem "dexter"
  gem "pghero"
  gem "pg_query", ">= 2"
  gem "rubocop", require: false
  gem "seed_dump"
  gem "solargraph-reek"
  gem "spring"
end

group "test" do
  gem "capybara"
  gem "cuprite"
  gem "database_cleaner"
  gem "launchy"
  gem "rails-controller-testing"
  gem "simplecov", require: false
  gem "timecop"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

gem "reline", "~> 0.3.2"
