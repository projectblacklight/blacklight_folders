Blacklight::Folders::Engine.routes.draw do
  resources :folders
  resources :folder_items, only: [:create, :destroy]
end
