CatalogController.index_tool_partials.delete(:bookmark)
CatalogController.add_index_tools_partial(:folder, partial: 'blacklight/folders/folder_control')
CatalogController.document_actions.delete(:bookmark)
CatalogController.add_document_action(:folder, partial: 'blacklight/folders/show/add_to_folder', if: Proc.new { |ctx| ctx.current_user } )

