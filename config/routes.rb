
Rails.application.routes.draw do

  get '/about' => 'home#about'
  get '/home/track' => 'home#track'
  root 'home#index'
end
