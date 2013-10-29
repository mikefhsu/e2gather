E2gather::Application.routes.draw do
  get "e2gather/index"
  
  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :events
  resources :users
  resources :ingredients

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'e2gather#index'
  
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'e2gather/loginFacebook' => 'e2gather#loginFacebook'
  get '/logout' =>'e2gather#logout'
  post 'e2gather/ingre' => 'e2gather#sendmail'
  post 'e2gather/sendmail' => 'e2gather#sendmail'
  get 'e2gather/render_event_page' => 'e2gather#render_event_page'
  post 'e2gather/create_user_event' => 'e2gather#create_user_event'
  get 'events/view_event_page/:e_id' => 'events#view_event_page'
  get 'events/select_guests/:e_id' => 'events#select_guests'
  post 'users/update_invitation' => 'users#update_invitation'
  get 'e2gather/errorpage' => 'e2gather#errorpage'
  get 'e2gather/render_ingredient_page' => 'e2gather#render_ingredient_page'
  post 'e2gather/create_ingredient' => 'e2gather#create_ingredient'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

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
