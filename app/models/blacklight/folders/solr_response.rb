module Blacklight::Folders
  class SolrResponse < Blacklight::SolrResponse
    attr_reader :doc_ids, :document_model

    def docs
      @docs ||= begin
        # Put them into the right order (same order as doc_ids),
        # and cast them to the right model.
        doc_ids.map.with_index {|id, i|
          doc_hash = self.documents.find{|doc| doc[document_model.unique_key] == id }
          raise "Couldn't find Solr document for #{document_model.unique_key}: `#{id}'" unless doc_hash
          doc_hash
        }
      end
    end

    def order= doc_ids
      @doc_ids = doc_ids
    end

    #Assume one document model for all docs in the solr response
    def document_model= document_model
      @document_model = document_model
    end
  end
end
