Rails.application.routes.draw do
  resources :chunks
  resources :videos
  get '/videos/:id/transcribe', to: 'videos#transcribe'
  root "videos#new"



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
