Blacklight::Folders::Engine.routes.draw do
  patch '/folders/add_bookmarks', to: 'folders#add_bookmarks', as: 'add_bookmarks_to_folder'
  patch '/folders/remove_bookmarks', to: 'folders#remove_bookmarks', as: 'remove_bookmarks_from_folder'
  resources :folders
end
