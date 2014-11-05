module Blacklight::Folders

  # Inherit from the main app's ApplicationController
  # so that we can inherit the main app's layout.
  class ApplicationController < ::ApplicationController

    include Blacklight::Folders::ApplicationControllerBehavior
    check_authorization

  end
end
