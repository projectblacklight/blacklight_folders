Blacklight::Folders::Engine.routes.draw do
  resources :folders, except: [:index]
  resources :folder_items, only: [:create, :destroy]
end
