source 'https://rubygems.org'
ruby '3.2.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.4'
gem 'sprockets-rails'

gem 'pg'

# Use Puma as the app server
gem 'puma', '>= 5.6.4'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'nokogiri', '>= 1.13.4'

gem 'bootsnap', require: false

gem 'haml'

gem 'friendly_id', '~> 5.1.0'

gem 'newrelic_rpm'

gem 'devise'

gem 'omniauth'

gem 'twilio-ruby', '~> 4.11.1'

gem 'activerecord-import'

gem 'jsbundling-rails'

gem 'cssbundling-rails'

gem 'turbo-rails'

gem 'stimulus-rails'

gem 'watir'

gem 'selenium-webdriver', '~> 4.4'
gem 'net-sftp'
gem 'ed25519'
gem 'bcrypt_pbkdf'

gem 'standard_deviation'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'factory_bot_rails'
  gem 'parallel_tests'
  gem 'rack-mini-profiler'
  gem 'rspec-rails', '~> 5.1.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'brakeman'
  gem 'bullet'
  gem 'erb_lint', require: false
  gem 'erblint-github'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'rack-livereload'
  gem 'listen', '~> 3.0.5'
  gem 'nested_scaffold'
  # gem 'reek', require: false
  gem 'rubocop', require: false
  gem 'seed_dump'
  gem 'solargraph-reek'
  gem 'spring'
  gem 'web-console'
end

group 'test' do
  gem 'apparition', github: 'twalpole/apparition', ref: 'ca86be4d54af835d531dbcd2b86e7b2c77f85f34'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'timecop'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'reline', '~> 0.3.2'
