# -*- encoding : utf-8 -*-
Kkdp::Application.routes.draw do
  # get '/tmp'=>'home#tmp'
  get '/tuan' => 'home#tuan'
  get '/cards' => 'home#cards'
  get '/exp' => 'home#exp'
  
# psvr>
resources :tags
# <psvr
# w>
get '/bugtrack'=>'application#bugtrack',:as => 'bugtrace'
get '/agreement'=>'home#agreement'
get '/under_construction' => 'home#under_construction',:as=>'under_construction'
get "traverse/index",as:'traverse'
get "traverse/asks_from",as:'asks_from'
get 'home/agreement'

get 'nb/*file' =>'application#nb'
root :to => "home#index"
get '/root'=>'home#index0'
match '/topics_follow' => 'topics#fol'
post '/topics_unfollow'=>'topics#unfol'  


scope 'embed',:as=>'embed' do
  controller "embed" do
    get '/search' => 'embed#search',:as=>:search
    get '/mail_icon'
  end
end
# <w

  match "/uploads/*path" => "gridfs#serve"
  match "/update_in_place" => "home#update_in_place"
  match "/muted" => "home#muted"
  match "/newbie" => "home#newbie"
  match "/followed" => "home#followed"
  match "/recommended" => "home#recommended"
  match "/mark_notifies_as_read" => "home#mark_notifies_as_read"
  match "/mute_suggest_item" => "home#mute_suggest_item"
  match "/report" => "home#report"
  match "/about" => "home#about"
  match "/doing" => "logs#index"

  # devise_for :users, :path => '', :path_names => {:sign_in => "login", :sign_out => "logout", :sign_up => "register", :registration }
  devise_for :users,  :controllers => { :registrations => "registrations" } do
    get "/register", :to => "registrations#new" 
    get "/login", :to => "devise/sessions#new" 
    get "/logout", :to => "devise/sessions#destroy" 
  end
  resources :users do
    member do
      get "answered"
      get "asked"
      get "asked_to"
      get "follow"
      get "unfollow"
      get "followers"
      get "following"
      get "following_topics"
      get "following_asks"
    end
  end
  match "auth/:provider/callback", :to => "users#auth_callback"  
  # match "auth/:provider/callback", :to => "home#auth_callback"  
  # match "auth/:provider/unbind", :to => "home#auth_unbind"  

  resources :search do
    collection do
      get "all"
      get "topics"
      get "asks"
      get "users"
    end
  end
  # special-----------------------------------
  resources :asks do
    member do
      get "spam"
      get "follow"
      get "unfollow"
      get "mute"
      get "unmute"
      post "answer"
      post "update_topic"
      get "update_topic"
      get "redirect"
      get "invite_to_answer"
      get "share"
      post "share"
    end
  end
  # ------------------------------------------
  resources :answers do
    member do
      get "vote"
      get "spam"
      get "thank"
    end
  end
  resources :comments 
  # special-----------------------------------------------------------------------------------
  resources :topics, :constraints => { :id => /[a-zA-Z\w\s\.%\-_]+/ } do
    member do
      get "follow"
      get "unfollow"
      get "show_s"
      get "show_cc"
    end
  end
  resources :logs
  resources :inbox
  # ------------------------------------bbs-------------------------------------------------------
  namespace :bbs do 
    resources :notes
    match "/file/*path" => "gridfs#serve"
    root :to => "topics#index"  

    resources :users, :path => "u", :only => :show

    resources :nodes

    match "n:id" => "topics#node", :as => :node_topics
    match "t/last" => "topics#recent", :as => :recent_topics
    resources :topics, :path => "t" do
      member do
        post :reply
      end
      collection do
        get :search
        get :feed
      end
    end
    resources :replies, :path => "r"
    resources :photos do
      collection do
        get :tiny_new
      end
    end
    
    namespace :cpanel do 
      root :to => "home#index"
      resources :replies
      resources :topics
      resources :nodes
      resources :sections
      resources :users
      resources :photos
    end  

  end

  # -------------------------------------------------------------------------------------------
  namespace :cpanel do
    root :to =>  "home#index"
    resources :users
    resources :asks
    resources :answers
    resources :topics
    resources :comments
    resources :report_spams
    resources :notices
    get '/stats' => 'stats#index',:as=>'stats'
    post '/stats/uv' => 'stats#uv'
    get '/autofollow' => 'autofollow#index',:as=>'autofollow'

  end

  mount Resque::Server, :at => "/cpanel/resque"
end
