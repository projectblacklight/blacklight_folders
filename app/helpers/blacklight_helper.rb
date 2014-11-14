module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Determine whether to render the bookmarks control
  def render_bookmarks_control?
    false
  end
end
