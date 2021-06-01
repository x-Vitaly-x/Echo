Rails.application.routes.draw do
  resources :endpoints

  match "*path", to: "endpoints#render_path", via: :all
end
