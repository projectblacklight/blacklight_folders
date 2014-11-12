# Load blacklight so that we can override blacklight views
require 'blacklight'
require 'acts_as_list'

module Blacklight::Folders
  class Engine < ::Rails::Engine
    isolate_namespace Blacklight::Folders

    initializer 'blacklight-folders.initialize' do
      require 'cancan'
    end

  end
end
