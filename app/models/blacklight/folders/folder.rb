module Blacklight::Folders
  class Folder < ActiveRecord::Base
    belongs_to :user, polymorphic: true
    validates :user, presence: true
    validates :name, presence: true

    after_initialize :default_values

    has_many :items, -> { order('position ASC') }, class_name: 'FolderItem', :dependent => :destroy
    has_many :bookmarks, -> { order('blacklight_folders_folder_items.position ASC') }, through: :items
    accepts_nested_attributes_for :items, allow_destroy: true

    # visibility
    PUBLIC = 'public'
    PRIVATE = 'private'
    before_save :apply_visibility

    # How many folders will appear in the drop-down menu
    MENU_LIMIT = 5

    def default_values
      self.number_of_members ||= 0
      self.visibility ||= Blacklight::Folders::Folder::PRIVATE
    end

    def recalculate_size
      self.number_of_members = items.count
    end

    def documents
      response.docs
    end

    def response
      @response ||= begin
        doc_ids = bookmarks.pluck(:document_id)
        # return [] if doc_ids.empty?

        rows = doc_ids.count
        query_ids = doc_ids.map{|id| RSolr.escape(id) }
        query_ids = query_ids.join(' OR ')

        query = query_ids.blank? ? '' : "id:(#{query_ids})"
        solr_repository.search(q: query, qt: 'document', rows: rows).tap do |response|
          response.order = doc_ids
        end
      end
    end

    def apply_visibility
      self.visibility ||= default_visibility
    end

    def add_bookmarks(doc_ids=[])
      doc_ids = Array(doc_ids)
      doc_ids.each do |doc_id|
        b = bookmarks.build(document_id: doc_id, user_id: user_id)
        b.document_type = blacklight_config.solr_document_model.to_s
      end
    end

    def remove_bookmarks(target=[])
      items.delete(target)
    end

    protected
      def default_visibility
        PRIVATE
      end

      def solr_repository
        @solr_repo ||= Blacklight::SolrRepository.new(blacklight_config)
      end

      def blacklight_config
         @blacklight_config ||= begin
           ::CatalogController.blacklight_config.deep_copy.tap do |config|
             config.solr_response_model = Blacklight::Folders::SolrResponse
           end
         end
      end

    class << self

      # Find the folders that belong to this user
      def for_user(user)
        if user.new_record?
          user.folders
        else
          accessible_by(user.ability, :update).order(:name)
        end
      end

      # Find the folders that contain this document
      def with_document(document)
        where("id in (#{membership_query(document)})")
      end

      # Find the folders that don't contain this document
      def without_document(document)
        where("id not in (#{membership_query(document)})")
      end

      def most_recent
        order('updated_at DESC')
      end

      def default_folder_name
        I18n.translate(:'blacklight.folders.default_folder_name')
      end

      private

        def membership_query(document)
          Blacklight::Folders::FolderItem.select(:folder_id).joins(:bookmark).where('bookmarks.document_id' => document.id).to_sql
        end

    end # class << self
  end
end
