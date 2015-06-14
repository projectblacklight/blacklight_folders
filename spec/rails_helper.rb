ENV["RAILS_ENV"] ||= 'test'

require 'spec_helper'

require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'blacklight_folders'

require 'factory_girl'
FactoryGirl.find_definitions


# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

require "support/features/sign_in"

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    if self.class.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!

  config.include Devise::TestHelpers, type: :controller
  config.include Features::SignIn, type: :feature
  config.include FactoryGirl::Syntax::Methods
end


def main_app
  Rails.application.class.routes.url_helpers
end

