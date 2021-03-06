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
  #post 'e2gather/ingre' => 'e2gather#sendmail'
  post 'e2gather/sendmail' => 'e2gather#sendmail'
  post 'e2gather/sendMessage' => 'e2gather#sendmsg'
  get 'e2gather/render_event_page' => 'e2gather#render_event_page'
  post 'e2gather/create_user_event' => 'e2gather#create_user_event'
  post 'e2gather/invite_guest' =>'e2gather#invite_guest'
  get 'e2gather/pick_guest_page/:e_id' =>'e2gather#pick_guest_page'
 
  get 'e2gather/render_ingredient_page' => 'e2gather#render_ingredient_page'
  post 'e2gather/create_ingredient' => 'e2gather#create_ingredient'
  get 'e2gather/show_ingredient/:id' => 'e2gather#show_ingredient' 
  get 'e2gather/edit_ingredient/:id' => 'e2gather#edit_ingredient' 
  patch 'e2gather/edit_ingredient/:id' => 'e2gather#update_ingredient'
  get  'e2gather/delete_ingredient/:id'=> 'e2gather#delete_ingredient' 
  delete 'e2gather/delete_ingredient/:id'=> 'e2gather#delete_ingredient'
  
  get 'events/view_event_page/:e_id' => 'events#view_event_page'
  get 'events/view_host_event_page/:e_id' => 'events#veiw_host_event_page'
  get 'events/select_guests/:e_id' => 'events#select_guests'
  post 'events/finalized' => "events#finalized"
  post 'users/update_invitation' => 'users#update_invitation'
  get 'e2gather/errorpage' => 'e2gather#errorpagenotfound'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get 'e2gather/render_ingredient_page' => 'e2gather#render_ingredient_page'
  post 'e2gather/create_ingredient' => 'e2gather#create_ingredient'
  get ':not_found'=> 'e2gather#errorpagenotfound'
  post ':not_found' => 'e2gather#errorpagenotfound'
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
