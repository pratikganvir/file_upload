SociaLoginRails::Application.routes.draw do

  root :to => 'pages#landing'
  namespace :admin do
    resources :users
    resources :admin_users
  end

  resources :roles

  resources :songs
   
  #match "/admin_users" => "users#admin_users", :via=>[:get]
  match "/add_email" => "users#add_email" , :via=>"get"
  match "/users/save_email"=> "users#save_email", :via=>"post"
  get "pages/terms"
  get "pages/welcome"
  get "pages/landing"
  match "/twitter" => 'pages#landing' ,:via=>"get"
  devise_for :users, :controllers => {:passwords => "passwords",:omniauth_callbacks=> "omniauth_callbacks",:sessions => "api/v1/sessions",:registrations=>"api/v1/registrations"}
 resources :users
  


  namespace :api do
    namespace :v1 do
      #Sessions controller
      devise_scope :user do
        resources :sessions, :only => [:create, :destroy,:update,:api_current_user]
        match 'api_current_user/:id' => "sessions#api_current_user" ,:via => :get
        #        match 'all_users' => "sessions#all_users" ,:via => :get
        match 'date_today' => "sessions#date_today", :via => :get   
        match 'reset_password' => "sessions#reset_password", :via => :post
        match 'users' => "registrations#create" ,:via=>[:post]
        match 'edit' => "registrations#update" ,:via=>[:post]
      end
    end
  end
end
