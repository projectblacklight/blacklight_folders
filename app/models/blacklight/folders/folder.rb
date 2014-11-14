module Blacklight::Folders
  class Folder < ActiveRecord::Base
    belongs_to :user, polymorphic: true
    validates :user_id, presence: true
    validates :name, presence: true

    after_initialize :default_values

    has_many :items, -> { order('position ASC') }, class_name: 'BookmarksFolder', :dependent => :destroy
    has_many :bookmarks, -> { order('blacklight_folders_bookmarks_folders.position ASC') }, through: :items

    # visibility
    PUBLIC = 'public'
    PRIVATE = 'private'
    before_save :apply_visibility

    # Find the folders that belong to this user and don't contain this document
    def self.without_doc_for_user(document, user)
      subquery = Blacklight::Folders::BookmarksFolder.select(:folder_id).joins(:bookmark).where('bookmarks.document_id' => document.id).to_sql

      where(user: user).where("id not in (#{subquery})")
    end

    def default_values
      self.number_of_members ||= 0
    end

    def recalculate_size
      self.number_of_members = items.count
    end

    def documents
      bookmarks.map(&:document)
    end

    def default_visibility
      PRIVATE
    end

    def apply_visibility
      self.visibility ||= default_visibility
    end

    def blacklight_config
      ::CatalogController.blacklight_config
    end

    def add_bookmarks(doc_ids=[])
      doc_ids.each do |doc_id|
        b = bookmarks.build(document_id: doc_id, user_id: user_id)
        b.document_type = blacklight_config.solr_document_model.to_s
      end
    end

    def remove_bookmarks(items=[])
      self.items.delete(items)
    end

  end
end
