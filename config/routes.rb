
Rails.application.routes.draw do
  get '/home/track' => 'home#track'
  root 'home#index'
end
