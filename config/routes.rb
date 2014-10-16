BlacklightFolders::Engine.routes.draw do
  resources :folders, except: [:index]
end
