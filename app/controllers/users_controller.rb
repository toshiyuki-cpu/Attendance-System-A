class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy edit_basic_info update_basic_info]
  before_action :logged_in_user, only: %i[index show edit update destroy edit_basic_info update_basic_info] # ログイン済みのユーザー
  before_action :correct_user, only: %i[edit_basic_info] # アクセスしたユーザーが現在ログインしているユーザーか
  before_action :admin_or_correct_user, only: %i[show edit edit_basic_info]
  before_action :admin_user, only: %i[index destroy edit_basic_info update_basic_info in_attendance_employees]
  before_action :set_one_month, only: :show

  def index
    # @users = User.all
    # ページネーションを判定できるオブジェクトに置き換える
    # paginateではキーが:pageで値がページ番号のハッシュを引数にとります。
    # User.paginateは:pageパラメータに基づき、データベースからひとかたまりのデータを取得
    # @users = User.paginate(page: params[:page]) 検索フォーム無しの場合
    # @users = User.paginate(page: params[:page]).search(params[:search]) 検索フォーム有りの場合
    @users = User.paginate(page: params[:page]).search(params[:search]).where.not(admin: true) # where.not(admin: true)管理者を表示させない
  end

  def show
    # @user = User.find(params[:id]) set_userへ
    # @first_day = Date.current.beginning_of_month #当日を取得するためDate.currentを使っています
    # Railsのメソッドであるbeginning_of_monthを繋げることで、当月の初日を取得することが可能
    # @last_day = @first_day.end_of_month
    # end_of_monthは当月の終日を取得することが可能
    @worked_sum = @attendances.where.not(started_at: nil).count
    # countメソッドは配列の要素数を取得することができます
    # 「1ヶ月分の勤怠データの中で、出勤時間が何も無い状態では無いものの数を代入」
    # @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    # 勤怠変更申請：attendanceオブジェクトからステータスがapplyingと上長idを取得
    @change_attendance_applyings = Attendance.where(change_attendance_superior_id: @user.id,
                                                    change_attendance_status: 'applying')

    # 勤怠変更申請をユーザーオブジェクトでグルーピング
    # @change_attendance_applying_group = Attendance.where(change_attendance_superior_id: @user.id, change_attendance_status: 'applying').group_by { |item| item.user }

    # 残業申請お知らせ通知
    @overtime_appliyings = Attendance.where(select_superior_id: @user.id, overtime_status: 'applying')

    # 残業申請をユーザーオブジェクトでグルーピング(モーダル表示のためattemdamcesコントローラーで定義に変更)
    # @applying_group = Attendance.where(select_superior_id: @user.id, overtime_status: 'applying').group_by { |item| item.user }

    # find_or_create_byメソッドとは、条件に合致したインスタンスがデータベースに保存されているかどうかをチェック
    # データベースに保存されている場合はfindメソッド
    # データベースに保存されていない場合は'create'メソッドとして、インスタンスの状況によって適用されるメソッドが異なる
    @month_report = @user.month_reports.find_or_create_by(user_id: current_user, month: params[:date])

    # 1ヶ月分の勤怠申請上長選択フォームで自分を表示させない
    @superiors = User.superior_except_me(current_user)

    # 1ヶ月分の勤怠申請お知らせ通知件数
    @month_report_applyings = MonthReport.where(approver_id: @user.id, status: 'applying')

    # 1ヶ月分の勤怠申請をユーザーオブジェクトでグルーピング（モーダル表示のためmonth_reportsコントローラーで定義に変更）
    # @report_receivings_group = MonthReport.where(approver_id: @user.id, status: 'applying').group_by { |item| item.user }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params) # (params[:user]) userコントローラーにシンボルparams[:user]として渡している
    if @user.save
      log_in @user # 保存成功後、ログインします。このメソッドによりリダイレクトされたページではログイ�����状態のレイアウトが表示される
      flash[:success] = '新規作成に成功しました。' #:successというキーには保存に成功した時のメッセージを代入
      redirect_to @user # 左記のように記述できる redirect_to user_url(@user)
    else
      render :new
    end
  end

  def edit
    # @user = User.find(params[:id]) set_userへ
  end

  def update
    # @user = User.find(params[:id]) set_userへ
    if @user.update_attributes(user_params)
      # user controllerのvalidationにallow_nil: trueオプションを追加するとパスワード入力しなくても更新できる
      flash[:success] = 'ユーザー情報を更新しました。'
      if current_user.admin?
        redirect_to users_url
      else
        redirect_to @user 
      end
    else
      render :edit
    end
  end

  def destroy
    # @user = User.find(params[:id]) set_userへ
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
    # @user = User.find(params[:id]) set_userへ
  end

  def update_basic_info
    # @user = User.find(params[:id]) set_userへ
    if @user.update_attributes(basic_info_params) # update_attributes バリデーションを通す
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join('<br>')
      # 今回は単純に文字列を連結（+により）してみました。
      # @user.errors.full_messagesは配列のため、joinメソッドを使って要素ごとに、で区切るよう指定しています
      # flash変数に任意のエラーメッセージとバリデーションにより生成されたエラーメッセージを合わせて代入して表示
      # application_controllerの<%= msg %>にhtml_safeメソッドを繋げています。
      # この実装により、エラーメッセージを配列の要素ごとに区切る際に指定した<br>がHTMLとして有効になり改行される仕組み
    end
    redirect_to users_url
  end

  # 出勤中社員一覧
  def in_attendance_employees
    @user = User.find(params[:id])
    # started_atが存在、finished_atがnil、本日であること
    @in_attendance_employees = Attendance.where.not(started_at: nil).where(finished_at: nil,
                                                                           worked_on: Time.current.to_date)
  end

  # csvファイルのインポート
  def import
    # privateにvalid_file?定義
    unless valid_file?
      flash[:danger] = 'CSVファイルを選択して下さい。'
      redirect_to users_url and return
    end
    begin
      # エラーが発生する処理（読み込みで例外が発生-->rescueへ）
      User.import(params[:file])
      flash[:success] = 'ユーザーを追加/更新しました'
      redirect_to users_url
    # return 失敗しなければここまで来る。
    # 途中でエラー(CSVのnewでエラーが起きたら)ここに飛ぶ
    # 復旧処理
    # インポート用ファイルではない時
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = 'インポート用ファイルではありません。'
      redirect_to users_url
    # CSVファイルに違うカラムが含まれてた時
    rescue CSV::MalformedCSVError
      flash[:danger] = '異なるデータが含まれてます。'
      redirect_to users_url
    end
  end

  # csvファイルのインポート
  # def import
  # if params[:file].blank?
  # flash[:danger] = '読み込むCSVを選択してください'
  # redirect_to users_url
  # elsif File.extname(params[:file].original_filename) != ".csv"
  # flash[:danger] =  'csvファイルのみ読み込み可能です'
  # redirect_to users_url
  # else
  # User.import(params[:file])
  # flash[:success] = "ユーザーを追加/更新しました"
  # redirect_to users_url
  # end
  # end

  private # Web経由で外部のユーザーが知る必要は無いため、次に記すようにRubyのprivateキーワードを用いて外部からは使用できないようにする

  # このメソッドは前述したparams[:user]の代わり
  def user_params
    params.require(:user).permit(:name, :email, :affiliation, :employee_number, :password, :password_confirmation) # Storong Parameter
    # 必須となるパラメータと許可されたパラメータを指定することができる
    # paramsハッシュでは:userキーを必須とする
  end

  def basic_info_params
    params.require(:user).permit(:affiliation, :basic_time, :work_time)
  end

  def valid_file?
    params[:file].present? && File.extname(params[:file].original_filename) == '.csv'
  end

  def admin_or_correct_user
    # どちらかの条件式がtrueか、どちらもtrueの時には何も実行されない処理。
    # このフィルターに引っかかった場合は、トップページへ強制移動
    @user = User.find(params[:user_id]) if @user.blank?
    # 上長の部下（部下の勤怠確認するため）roleがsuperiorのidの時
    
    # 下記のidとcurrent_userが同じidなら部下。上長は部下の勤怠閲覧できる
    # select_superior_id(残業申請)attendanceモデル
    # change_attendance_superior_id（勤怠変更申請）attendanceモデル
    # approver_id（1ヶ月分の勤怠申請）month_reportモデル
    
    @subordinate = User.joins(:attendances).merge(Attendance.where(select_superior_id: @user.id).or (Attendance.where(change_attendance_superior_id: @user.id)))
    unless current_user?(@user) || current_user.admin? || current_user.role.superior?
    flash[:danger] = '編集権限がありません。'
    redirect_to(root_url)
    end
  end

  def admin_user
    unless current_user.admin?
    flash[:danger] = '編集権限がありません。'
    redirect_to(root_url)
    end
  end
end

# applocation_controllerへ移動１２２行目まで
# beforeフィルター

# paramsハッシュからユーザーを取得します。
# def set_user # show,edit,updateアクションの@user = User.find(params[:id])をset_userとして定義
#   @user = User.find(params[:id])
# end

# ログイン済みのユーザーか確認
# def logged_in_user
# unless logged_in? # unlessは条件式がfalseの場合のみ記述した処理が実行される構文
# store_location
# flash[:danger] = "ログインしてください。"
# redirect_to login_url
# end
# end
# end

# アクセスしたユーザーが現在ログインしているユーザーか確認
# def correct_user
#   @user = User.find(params[:id]) # アクセスしたユーザーを判定するため
#   redirect_to(root_url) unless current_user?(@user) #current_user?(user) sessionsヘルパーで定義してある
# end

# システム管理権限所有かどうか判定
