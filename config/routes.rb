SociaLoginRails::Application.routes.draw do

  resources :songs

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "/add_email" => "users#add_email" , :via=>"get"
  match "/users/save_email"=> "users#save_email", :via=>"post"
  get "pages/terms"
  get "pages/welcome"
  get "pages/landing"
  devise_for :users, :controllers => {:passwords => "passwords",:omniauth_callbacks=> "omniauth_callbacks"}
  resources :users,:only=> [:show, :edit, :update]
  root :to => 'pages#landing'
  ActiveAdmin.routes(self)
end
