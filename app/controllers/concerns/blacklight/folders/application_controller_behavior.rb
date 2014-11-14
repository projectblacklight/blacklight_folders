module Blacklight::Folders
  module ApplicationControllerBehavior
    extend ActiveSupport::Concern

    included do
      layout 'blacklight/folders/application'

      rescue_from ::CanCan::AccessDenied do |exception|
        if current_user
          redirect_to main_app.root_url, alert: exception.message
        else
          redirect_to main_app.new_user_session_path, alert: 'Please sign in to continue.'
        end
      end
    end
  end
end
