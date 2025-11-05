Rails.application.routes.draw do
  namespace :in, defaults: { namespace: 'in' } do
    root 'home#index'
    controller :home do
      get :index
      get :organs
    end
  end

  namespace :board, defaults: { namespace: 'board' } do
    root 'home#index' unless has_named_route? 'board_root'
    controller :home do
      get :index
    end
  end

  namespace :mem, defaults: { namespace: 'mem' } do
    root 'home#index'
  end

  namespace 'org', defaults: { business: 'org' } do
    resources :members, only: [:index, :show] do
      collection do
        get :search
      end
    end
    resources :organs, only: [:index, :show] do
      collection do
        get :form_search
      end
    end

    namespace :me, defaults: { namespace: 'me' } do
      root 'home#index'
      resource :member, except: [:new, :create] do
        member do
          get :qrcodes
          get :qrcode
        end
      end
      resource :organs, except: [:new, :create]
      resource :resign
      resources :departments
      resources :tutorials do
        collection do
          get :tutorings
        end
        member do
          get :perform
        end
      end
      resources :job_transfers do
        get :departments, on: :collection
      end
    end

    namespace :board, defaults: { namespace: 'board' } do
      root 'home#index'
      resources :organs do
        collection do
          post :create_admin
        end
        member do
          match :redirect, via: [:get, :post]
        end
      end
      resources :members, only: [:index, :new, :create] do
        collection do
          get :near
          match :logout, via: [:get, :post]
        end
        member do
          match :user_login, via: [:get, :post]
          match :login, via: [:get, :post]
        end
      end
    end

    namespace :panel, defaults: { namespace: 'panel' } do
      root 'home#index'
      resources :organs do
        collection do
          post :search
        end
        member do
          get :children
          post :edit_roles
        end
        resources :organ_domains
        resources :members do
          member do
            post :mock
            post :edit_roles
          end
        end
      end
      resources :organ_domains, only: [] do
        collection do
          get :all
        end
      end
      resources :members, only: [] do
        collection do
          get :all
        end
      end
    end

    namespace :admin, defaults: { namespace: 'admin' } do
      root 'home#index'
      controller :home do
        get :index
      end
      resource :current_organ, controller: 'current_organ'
      resources :organs do
        collection do
          get :all
        end
        member do
          post :edit_roles
        end
        resources :organ_domains
      end
      resources :departments do
        collection do
          get :supports
          get :parents
          get :my
          get :search
          get :filter
        end
        member do
          get :need
        end
        resources :job_titles do
          collection do
            post 'department' => :create_department
          end
          member do
            patch :move_lower
            patch :move_higher
            patch :reorder
          end
        end
        resources :job_descriptions
      end
      resources :super_job_titles do
        member do
          patch :move_lower
          patch :move_higher
          patch :reorder
        end
      end
      resources :members do
        collection do
          get :options
          get :departments
          get :leaders
          patch :sync_all
          get 'add_item/:item' => :add_item, as: :add_item
          get 'remove_item/:item' => :remove_item, as: :remove_item
        end
        member do
          post :edit_roles
          get :token
          patch :mock
        end
        resources :member_departments do
          collection do
            get :options
          end
          member do
            get 'options' => :member_options
          end
        end
        resources :authorized_tokens
      end
      resources :supports do
        collection do
          get :departments
        end
      end
      resources :tutorials do
        collection do
          get :my
        end
      end
      resources :job_transfers do
        member do
          patch :trigger
        end
        collection do
          get :my
        end
      end
      resources :resigns do
        collection do
          get :my
          get :charts
        end
      end
      resources :resign_reasons do
        collection do
          get :parents
        end
      end
      resources :shortcuts
      scope ':record_class/:record_column' do
        resources :department_grants
      end
    end

    namespace :group, defaults: { namespace: 'group' } do
      resources :members
    end

    namespace :my, defaults: { namespace: 'my' } do
      resource :authorized_token
    end

  end
end
