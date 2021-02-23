# == Route Map
#
#                                         Prefix Verb   URI Pattern                                                                  Controller#Action
#                                           root GET    /                                                                            static_pages#top
#                                         signup GET    /signup(.:format)                                                            users#new
#                                          login GET    /login(.:format)                                                             sessions#new
#                                                POST   /login(.:format)                                                             sessions#create
#                                         logout DELETE /logout(.:format)                                                            sessions#destroy
#                               edit_basis_basis GET    /bases/:id/edit_basis(.:format)                                              bases#edit
#                                          bases GET    /bases(.:format)                                                             bases#index
#                                                POST   /bases(.:format)                                                             bases#create
#                                      new_basis GET    /bases/new(.:format)                                                         bases#new
#                                     edit_basis GET    /bases/:id/edit(.:format)                                                    bases#edit
#                                          basis GET    /bases/:id(.:format)                                                         bases#show
#                                                PATCH  /bases/:id(.:format)                                                         bases#update
#                                                PUT    /bases/:id(.:format)                                                         bases#update
#                                                DELETE /bases/:id(.:format)                                                         bases#destroy
#                          attend_employees_user GET    /users/:id/attend_employees(.:format)                                        users#attend_employees
#                           edit_basic_info_user GET    /users/:id/edit_basic-info(.:format)                                         users#edit_basic_info
#                         update_basic_info_user PATCH  /users/:id/update_basic_info(.:format)                                       users#update_basic_info
#                attendances_edit_one_month_user GET    /users/:id/attendances/edit_one_month(.:format)                              attendances#edit_one_month
#              attendances_update_one_month_user PATCH  /users/:id/attendances/update_one_month(.:format)                            attendances#update_one_month
#                      attendances_edit_log_user GET    /users/:id/attendances/edit_log(.:format)                                    attendances#edit_log
#   attendances_edit_overtime_work_end_plan_user GET    /users/:id/attendances/edit_overtime_work_end_plan(.:format)                 attendances#edit_overtime_work_end_plan
# attendances_update_overtime_work_end_plan_user PATCH  /users/:id/attendances/update_overtime_work_end_plan(.:format)               attendances#update_overtime_work_end_plan
#       attendances_overtime_approval_reply_user PATCH  /users/:id/attendances/overtime_approval_reply(.:format)                     attendances#overtime_approval_reply
#        user_attendance_overtime_approval_reply PATCH  /users/:user_id/attendances/:attendance_id/overtime_approval_reply(.:format) attendances#overtime_approval_reply
#                                user_attendance PATCH  /users/:user_id/attendances/:id(.:format)                                    attendances#update
#                                                PUT    /users/:user_id/attendances/:id(.:format)                                    attendances#update
#                                          users GET    /users(.:format)                                                             users#index
#                                                POST   /users(.:format)                                                             users#create
#                                       new_user GET    /users/new(.:format)                                                         users#new
#                                      edit_user GET    /users/:id/edit(.:format)                                                    users#edit
#                                           user GET    /users/:id(.:format)                                                         users#show
#                                                PATCH  /users/:id(.:format)                                                         users#update
#                                                PUT    /users/:id(.:format)                                                         users#update
#                                                DELETE /users/:id(.:format)                                                         users#destroy

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
  
    collection { post :import }
    
    member do #生成されたurlにuserを識別するための:idが自動で追加されます（collection(集合)はidなし、member(個別)はidあり）
      get 'attendances/csv_output' #勤怠のcsv出力
      get 'in_attendance_employees' #出勤中社員一覧
      get 'edit_basic-info' #ルーティング設定してアクションを定義
      patch 'update_basic_info' #ルーティング設定してアクションを定義
      get 'attendances/editing_one_month' # 勤怠変更申請まとめて送信用
      patch 'attendances/updating_one_month' # 勤怠変更申請まとめて送信用
      get 'attendances/overtime_index' # 社員からの残業申請表示（まとめて返信用ルーティング）
      patch 'attendances/overtime_reply' # 社員からの残業申請一括返信（まとめて返信用ルーティング）
      get 'attendances/receiving_one_month' # 社員からの勤怠変更申請表示（まとめて返信用ルーティング）
      patch 'attendances/reply_one_month' # 社員からの勤怠変更申請一括返信（まとめて返信用ルーティング）
      get 'month_reports/receiving_employee' # 社員から1ヶ月の勤怠申請表示（まとめて返信用ルーティング）
      patch 'month_reports/reply_employee' # 社員から1ヶ月の勤怠申請一括返信（まとめて返信用ルーティング）
      get 'attendances/edit_log' #勤怠ログ
    end
    
    # resourcesでonly:またはexcept:オプションを使用することで、主要な7つのアクション(index, show, new, create, edit, update, destroy)を限定することができます
    # index =>  /users/1/attendances
    resources :attendances, only: :update do # ネストさせる（1人のユーザーはたくさんのアテンダンスを持っている）
      patch 'overtime_approval_reply' # /users/:user_id/attendances/:attendance_id/overtime_approval_reply
      get 'edit_overtime_work_end_plan' # /users/:user_id/attendances/:attendance_id/edit_overtime_work_end_plan
      patch 'update_overtime_work_end_plan' # /users/:user_id/attendances/:attendance_id/update_overtime_work_end_plan
      patch 'change_attendance_approval_reply' #  /users/:user_id/attendances/:attendance_id/change_attendance_approval_reply
    end
    
    resources :month_reports do 
      # patch 'receiving' # 上長ページにひとまず表示させる(モーダルにするから必要ない)
      get 'receiving_index' # 通知からモーダル表示
      patch 'reply'
    end
  end
    # onlyオプションで指定することで、updateアクション以外のルーティングを制限できます
  # Usersリソースのブロック内に記述しているため、設定されるルーティングは
  # HTTP PATCH
  # URL /users/:user_id/attendances/:id  params[:user_id]でユーザーIDが取得できる
  # PATH user_attendance_path	
  # コントローラー#アクション attendances#update となる
 
  # get '/overtime_approval_index', to: 'attendances#overtime_approval_index' 
  
end
