class BookmarkMigrator

  attr_reader :errors

  def initialize(options={})
    @verbose = options[:verbose]
    @logging = options[:logging]
    @errors = []
    @default_folder_name = I18n.translate(:'blacklight.folders.default_folder_name')
  end

  def migrate
    raise 'Default folder name is not defined' if @default_folder_name.match(/translation missing/)
    @errors = []
    log_message 'Begin migration of existing bookmarks.'

    User.where(guest: false).find_each do |user|
      folder = default_folder(user)
      bookmarks_to_add = user.bookmarks - folder.bookmarks
      bookmarks_to_add.map do |b|
        folder.items.build(bookmark: b)
      end

      unless folder.save
        msg = "Unable to save bookmarks to folder: #{folder.id}"
        log_message "ERROR: #{msg}"
        @errors << msg
      end
    end

    log_message "Migration complete with #{@errors.count} errors."
    @errors.empty?
  end

  def default_folder(user)
    folder = user.folders.where(name: @default_folder_name).first
    folder ||= user.create_default_folder
  end

  def log_message(message)
    puts message if @verbose
    Rails.logger.info "#{self.class}: #{message}" if @logging
  end

end
