Rails.application.routes.draw do

  resources :changes, except: [:new, :edit]
  namespace :api do
    api version: 1, module: 'v1' do
      resources :sessions, only: [:create]
      resources :songs, only: [:index, :show, :destroy]
      get 'syncWithWeb', to: 'songs#syncWithWeb'
      get 'songs/setInRealm'
      get 'songs/setNotInRealm'
      #delete 'songs/destroy'
      resources :changes, only: [:index]
      get 'changes/clear'
    end
  end

  #resources :changes, only: [:index]

  get 'welcome/index'
  resources :songs do
    collection do
      delete :destroy_multiple
    end
  end
  devise_for :users

  root 'welcome#index'

  #namespace :v2 do
   # resources :users
  #end
 # match 'v:api/*path', :to => redirect("/api/v2/%{path}")
 # match '*path', :to => redirect("/api/v2/%{path}")

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
