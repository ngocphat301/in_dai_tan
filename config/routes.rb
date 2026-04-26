Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations" }

  get "robots.txt", to: "robots#show", as: :robots, defaults: { format: :text }
  get "sitemap.xml", to: "sitemaps#index", as: :sitemap, defaults: { format: :xml }

  root "home#index"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact", as: :contact
  get "search", to: "searches#index", as: :search
  get "search/suggest", to: "search_suggestions#index", as: :search_suggestions, defaults: { format: :json }
  resources :quote_requests, only: [ :create ]
  resources :ad_leads, only: [ :create ]
  resources :products, only: %i[index show]
  # Static paths must stay before `resources … path: "blog"` (reserved vs post slugs).
  get "blog/services", to: "blog_posts#service_index", as: :blog_services
  get "blog/projects", to: "blog_posts#project_index", as: :blog_projects
  resources :blog_posts, path: "blog", only: %i[index show], param: :slug

  namespace :admin do
    root to: "blog_posts#index"
    resources :users, except: [ :show ] do
      member do
        patch :toggle_role
      end
    end
    resources :product_categories, except: [ :show ]
    resources :blog_posts do
      member do
        patch :toggle_status
      end
    end
    resources :site_images, except: [ :show ]
    resources :quote_requests, only: %i[index edit update] do
      member do
        patch :toggle_staff_received
      end
    end
    resources :products do
      member do
        patch :toggle_published
      end
      resources :images, only: [ :new, :create, :edit, :update, :destroy ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
