# Remove bookmark from the navbar
CatalogController.blacklight_config.navbar.partials.delete(:bookmark)
# Remove bookmark from catalog#index
CatalogController.blacklight_config.index.document_actions.delete(:bookmark)
# Remove bookmark from catalog#show
CatalogController.blacklight_config.show.document_actions.delete(:bookmark)


CatalogController.add_index_tools_partial(:folder, partial: 'blacklight/folders/folder_control')
CatalogController.add_show_tools_partial(:folder, partial: 'blacklight/folders/show/add_to_folder')
CatalogController.add_nav_action(:folder, partial: 'blacklight/nav/folders', if: Proc.new { |ctx| ctx.current_ability.can?(:index, Blacklight::Folders::Folder)  } )
