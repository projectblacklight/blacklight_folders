source "https://rubygems.org"

# Declare your gem's dependencies in blacklight_folders.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec


# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
gem 'byebug', group: [:development, :test] unless ENV['TRAVIS']

# If we don't specify 2.11.0 we'll end up with sprockets 2.12.0 in the main
# Gemfile.lock but since sass-rails gets generated (rails new) into the test app
# it'll want sprockets 2.11.0 and we'll have a conflict
gem 'sprockets', '2.11.0'

# If we don't specify 3.2.15 we'll end up with sass 3.3.2 in the main
# Gemfile.lock but since sass-rails gets generated (rails new) into the test app
# it'll want sass 3.2.0 and we'll have a conflict
gem 'sass', '~> 3.2.0'
gem 'blacklight', github: 'projectblacklight/blacklight'
gem 'poltergeist'
gem 'database_cleaner'

file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
if File.exists?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
else
  if ENV['RAILS_VERSION']
    gem 'rails', ENV['RAILS_VERSION']
  else
    # explicitly include sass-rails to get compatible sprocket dependencies
    gem 'sass-rails'
  end
end
