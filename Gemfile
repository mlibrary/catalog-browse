source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'sinatra'
gem 'thin'
gem 'slim'

group :development do
  gem 'sinatra-contrib'
  gem 'listen'
end
group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'rack-test'
  gem 'rspec'
  gem 'webmock'
  gem 'simplecov'
  gem 'climate_control'
end
