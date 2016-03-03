Rails.application.routes.draw do
  root to: "landing_pages#landing"

  # custom routes
  get    :landing,     to: "landing_pages#landing",      as: :landing
  get    :signin,      to: "sessions#new",               as: :signin
  get    :signup,      to: "users#new",                  as: :signup

  # maybe make into a named resource
  get    :request_password,        to: "password_resets#request_password", as: :request_password
  get    "/reset_password/:token", to: "password_resets#reset_password",   as: :reset_password
  patch  "/reset_password/:token", to: "password_resets#update",           as: :password_reset
  post   "/contact",               to: "support#contact_us_email",         as: :contact_us


  # resource routes
  resources :users do
    resources :subscriptions, only: [:new, :create] do
      # there is only one subscription per user so no need to send subscription id
      get    'edit',    on: :collection
      delete 'destroy', on: :collection
    end
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :password_resets, only: [:create]
  resources :code_checks, only: [:index]
  resources :save_passwords, only: [:index]

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
