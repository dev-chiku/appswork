Rails.application.routes.draw do
  get '/templates/:path.html' => 'templates#template', constraints: { path: /.+/ }
  
  scope '/api' do
    resources :connections
  
    resources :notices, :only => [:list] do
      collection do
        get 'list'
      end
    end
  
    resources :notifications, :only => [:delete] do
      collection do
        get 'list'
        delete 'delete'
      end
    end
  
    resources :item_proposes, :only => [:show, :create]
  
    resources :messages, :only => [:list, :create] do
      collection do
        get 'list'
        post 'propose'
      end
    end
  
    resources :item_favorites, :only => [:create]
  
   resources :users, :only => [:show, :login, :mypage, :list, :logout, :create, :update_user, :upload] do
      collection do
        get 'list'
        get 'login'
        get 'logout'
        get 'mypage'
        get 'mail_auth'
        put 'update_user'
        post 'upload'
      end
    end
  
    resources :item_comments, :only => [:list, :create] do
      collection do
        get 'list'
      end
    end
  
    resources :items, :only => [:index, :show, :list, :detail, :entry, :create] do
      collection do
        get 'index'
        get 'list'
        get 'detail'
        get 'entry'
      end
    end
    
  end

  get '/work' => 'templates#index'
  get '/message' => 'templates#index'
  get '/message/:id' => 'templates#index'
  get '/message/target/:id' => 'templates#index'
  get '/employer/:id' => 'templates#index'
  get '/work/detail/:id' => 'templates#index'
  get '/mypage' => 'templates#index'
  get '/mypage/:id' => 'templates#index'
  get '/employer/:id' => 'templates#index'
  get '/connection' => 'templates#index'
  get '/privacypolicy' => 'templates#index'
  get '/agreement' => 'templates#index'
  

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'layouts#index'

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
