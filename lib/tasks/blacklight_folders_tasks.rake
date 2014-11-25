namespace :blacklight_folders do
  namespace :db do

    desc "Convert existing bookmarks to a folder with bookmarks"
    task :migrate_data => :environment do
      require 'migration/bookmark_migrator'
      migrator = BookmarkMigrator.new(verbose: true, logging: true)
      migrator.migrate
    end

  end
end
