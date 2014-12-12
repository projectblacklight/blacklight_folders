module Blacklight::Folders
  class SolrResponse < Blacklight::SolrResponse
    attr_reader :doc_ids
    def docs
      @docs ||= begin
        # Put them into the right order (same order as doc_ids),
        # and cast them to the right model.
        doc_ids.map.with_index {|id, i|
          doc_hash = (response['docs'] || []).find{|doc| doc['id'] == id }
          raise "Couldn't find Solr document for id: `#{id}'" unless doc_hash
          doc_hash
        }
      end
    end

    def order= doc_ids
      @doc_ids = doc_ids
    end
  end
end
