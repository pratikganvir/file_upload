SociaLoginRails::Application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "/add_email" => "users#add_email" , :via=>"get"
  match "/users/save_email"=> "users#save_email", :via=>"post"
  get "pages/terms"
  get "pages/welcome"
  get "pages/landing"
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" } do
    get '/reset_password' => "passowrdusers#new", :as => :reset_password
    get '/new_password' => "passwordusers#edit", :as => :new_password
    post '/send_email' => 'passwordusers#create', :as => :create_password
    put '/change' =>  'passwordusers#update', :as => :update_password
  end
  resources :users
  root :to => 'pages#landing'
  ActiveAdmin.routes(self)
end
