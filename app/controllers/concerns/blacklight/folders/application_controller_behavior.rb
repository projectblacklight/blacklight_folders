module Blacklight::Folders
  module ApplicationControllerBehavior
    extend ActiveSupport::Concern

    included do
      rescue_from ::CanCan::AccessDenied, with: :unauthorized_access
      before_action :give_guest_a_folder, if: :build_a_folder_for_guests?

      define_callbacks :logging_in_user
      set_callback :logging_in_user, :before, :transfer_guest_user_folders_to_current_user

    end

    # Override cancan to be aware of guest users
    def current_ability
      @current_ability ||= ::Ability.new(current_or_guest_user)
    end

    # Called when a CanCan error is raised. Redirects to the root page and sets a
    # flash error if the user is signed in, othewise tells the user to sign in.
    def unauthorized_access(exception)
      if current_user
        redirect_to main_app.root_url, alert: exception.message
      else
        redirect_to main_app.new_user_session_path, alert: 'Please sign in to continue.'
      end
    end

    # Build a folder on the current user so that the nav menu and Folder index page can be displayed
    def give_guest_a_folder
      current_or_guest_user.folders.build id: 0,
                                          name: Blacklight::Folders::Folder.default_folder_name,
                                          created_at: Time.now,
                                          updated_at: Time.now
    end

    # Test to see if the current user needs to have a folder built
    # Returns true when it's a guest who has no folders
    def build_a_folder_for_guests?
      current_or_guest_user.new_record? && current_or_guest_user.folders.empty?
    end

    private

      def transfer_guest_user_folders_to_current_user
        return unless respond_to? :current_user and respond_to? :guest_user and current_user and guest_user
        current_user_folders = current_user.folders
        guest_user.folders.each do |f|
          f.update(user: current_user)
        end
      end

  end
end
