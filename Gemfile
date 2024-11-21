source "https://rubygems.org"
ruby "3.3.5"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "activerecord-import"
gem "bcrypt_pbkdf"
gem "bootsnap", require: false
gem "cssbundling-rails"
gem "devise", git: "https://github.com/heartcombo/devise"
gem "ed25519"
gem "friendly_id", "~> 5.1.0"
gem "haml"
gem "jbuilder", "~> 2.5"
gem "jquery-rails"
gem "jsbundling-rails"
gem "logger"
gem "net-sftp"
gem "newrelic_rpm"
gem "nokogiri"
gem "omniauth"
gem "ostruct"
gem "pg"
gem "puma", ">= 6.4.0"
gem "rails", "~> 8.0.0"
gem "sprockets-rails"
gem "standard_deviation"
gem "stimulus-rails"
gem "turbo-rails"
gem "uglifier", ">= 1.3.0"
gem "watir"

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "brakeman"
gem "bullet", "~> 8.0"
  gem "dexter"
  gem "erb_lint", require: false
  gem "erblint-github"
  gem "guard"
  gem "guard-livereload", "~> 2.5", require: false
  gem "guard-rspec", require: false
  gem "listen", "~> 3.8.0"
  gem "nested_scaffold"
  gem "pghero"
  gem "pg_query", ">= 2"
  gem "rack-livereload"
  gem "rubocop", require: false
  gem "seed_dump"
  gem "solargraph-reek"
  gem "spring"
  # gem "web-console"
  # gem 'reek', require: false
end

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

# gem "reline", "~> 0.3.2"

