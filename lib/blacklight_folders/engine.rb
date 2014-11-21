# Load blacklight so that we can override blacklight views
require 'blacklight'
require 'acts_as_list'
require 'cancan'
require 'select2-rails'

module Blacklight::Folders
  class Engine < ::Rails::Engine
    isolate_namespace Blacklight::Folders
  end
end
