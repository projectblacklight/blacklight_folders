module Blacklight::Folders
  class ApplicationController < ActionController::Base
    include Blacklight::Folders::ApplicationControllerBehavior
    check_authorization
  end
end
