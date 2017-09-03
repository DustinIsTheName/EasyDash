Rails.application.routes.draw do
  
  controller :sessions do
    get 'login' => :new, :as => :login
    post 'login' => :create, :as => :authenticate
    get 'auth/shopify/callback' => :callback
    get 'logout' => :destroy, :as => :logout
  end

  namespace :search do
    get '/product' => :products
    get '/blog' => :blogs
    get '/collection' => :collections
    get '/custom_collection' => :custom_collection
    get '/page' => :pages
  end

  root :to => 'home#index'
  get '/activatecharge' => 'home#activate_charge'
  get '/sync-store' => 'home#sync_store'

  controller :unembedded do
    get '/preview-window' => :quick_select
    get '/dashboard' => :dashboard
    post '/dashboard-new' => :new_api
    put '/dashboard-update' => :update_api
    post '/dashboard-delete' => :delete_api
    get '/dashboard-hard-delete' => :hard_delete_api
    post '/dashboard-bulk-delete' => :bulk_delete_api
    post '/duplicate-product' => :duplicate_product
    post '/variant-update' => :update_variant
    post '/variant-image' => :update_variant_image
    post '/reorder-variants' => :reorder_variants
    post '/edit-options' => :edit_options
    post '/add-product-images' => :add_product_images
    post '/add-image-from-url' => :add_image_from_url
    post '/add-image-to-theme' => :add_image_to_theme
    post '/change-image-order' => :change_image_order
    post '/delete-image' => :delete_image
    get '/alt-tag' => :get_alt_tag
    post '/alt-tag' => :edit_alt_tag
    get '/variant-hsc' => :get_variant_hsc
    get '/resource-seo' => :get_resource_seo
    get '/ajax-resources' => :ajax_get_resources
    get '/refresh-form' => :refresh_form
    get '/refresh-variant-panel' => :refresh_variant_panel
    get '/product-tags' => :get_product_tags
    get '/product-types' => :get_product_types
    get '/product-vendors' => :get_product_vendors
    post '/app-uninstall' => :app_uninstall
  end
  
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
