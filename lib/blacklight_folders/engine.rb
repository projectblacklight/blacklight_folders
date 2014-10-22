# Load blacklight so that we can override blacklight views
require 'blacklight'

module Blacklight::Folders
  class Engine < ::Rails::Engine
    isolate_namespace Blacklight::Folders
  end
end
