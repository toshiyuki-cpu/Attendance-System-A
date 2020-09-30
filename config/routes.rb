Rails.application.routes.draw do

  root 'static_pages#top'
  get  '/signup', to: 'users#new'

  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :bases do
    member do
    get '/edit_basis', to: 'bases#edit'
    end
  end

  resources :users do #4つの基本操作（POST GET PATCH DELETE）が定義されている

  member do #生成されたurlにuserを識別するための:idが自動で追加されます
    get 'attend_employees' #出勤中社員一覧
    get 'edit_basic-info' #ルーティング設定してアクションを定義
    patch 'update_basic_info' #ルーティング設定してアクションを定義
    get 'attendances/edit_one_month' #ルーティング設定してアクションを定義
    patch 'attendances/update_one_month' #ルーティング設定してアクションを定義
    get 'attendances/edit_log' #勤怠ログ
    get 'attendances/edit_overtime_work_end_plan'
    patch 'attendances/update_overtime_work_end_plan'
  end

  resources :attendances, only: :update # onlyオプションで指定することで、updateアクション以外のルーティングを制限できます
  # Usersリソースのブロック内に記述しているため、設定されるルーティングは
  # HTTP　PATCH
  # URL /users/:user_id/attendances/:id　　params[:user_id]でユーザーIDが取得できる
  # PATH user_attendance_path	
  # コントローラー#アクション　attendances#update　となる

  end
end
