module Blacklight::Folders
  class Folder < ActiveRecord::Base
    belongs_to :user, polymorphic: true
    validates :user_id, presence: true
    validates :name, presence: true

    after_initialize :default_values

    # 999999999999999
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
      doc_ids = bookmarks.pluck(:document_id)
      return [] if doc_ids.empty?

      rows = doc_ids.count
      query_ids = doc_ids.map{|id| RSolr.escape(id) }
      query_ids = query_ids.join(' OR ')

      response = Blacklight.solr.select(params: { q: "id:(#{query_ids})", qt: 'document', rows: rows})['response']['docs']

      docs = response.reduce({}) {|hash, doc|
        hash.merge(doc['id'] => doc)
      }

      # Put them into the right order (same order as doc_ids),
      # and cast them to the right model.
      model_names = bookmarks.pluck(:document_type)
      doc_ids.zip(model_names).map do |doc_id, model_name|
        model_name.safe_constantize.new(docs[doc_id])
      end
    end

    def default_visibility
      PRIVATE
    end

    def apply_visibility
      self.visibility ||= default_visibility
    end

    def add_bookmarks(doc_ids=[])
      doc_ids.each do |doc_id|
        b = bookmarks.build(document_id: doc_id, user_id: user_id)
        b.document_type = b.default_document_type.to_s
      end
    end

    def remove_bookmarks(items=[])
      items.each do |item|
        item.destroy
      end
    end

  end
end
