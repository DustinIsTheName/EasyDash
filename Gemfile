source 'https://rubygems.org'

ruby '2.3.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.3'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', group: [:development, :test]

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

# delaying jobs
gem 'daemons'
gem 'delayed_job_active_record'

gem 'shopify_app', '6.2.0'
gem 'shopify_cli', group: :development
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'rest-client'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# AJAX upload files
gem 'remotipart', '~> 1.2'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem "wysiwyg-rails"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # new devlopment server that allows for the use of https
  gem 'thin'
  # includes RSpec itself in a wrapper to make it play nicely with Rails 3; hoping it does the same in rails 4
  gem 'rspec-rails'
  # replaces Rails’ default fixtures for feeding test data to the test suite with much more preferable factories
  gem 'factory_girl_rails'
end

# Access an IRB console on exception pages or by using <%= console %> in views
gem 'web-console', '~> 2.0', group: :development

