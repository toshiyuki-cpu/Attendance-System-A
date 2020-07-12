class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
#コントローラでヘルパーを使いたい場合はモジュールを読み込ませる必要があるが、
#全コントローラの親クラスであるapplication_controller.rbにこのモジュールを読み込ませることで、
#どのコントローラでもヘルパーに定義したメソッドが使えるようになる

  # $ グローバル変数は極端に言うとプログラムのどこからでも呼び出すことのできる変数
  $days_of_the_week = %w{日 月 火 水 木 金 土} # Rubyのリテラル表記
  
  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
    # @first_day = Date.current.beginning_of_month
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    #三項演算子(結果を戻り値として返す)
    
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。showアクションでは使わない為ローカル変数に代入
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    #worked_onをキーとして定義済みのインスタンス変数を範囲として指定しています
    #order(worked_on) 取得したAttendanceモデルの配列をworked_onの値をもとに昇順に並び替えます
    
    # ==演算子により一致した場合はtrue、一致しない場合はfalseが返されるため内部の処理が制御される仕組み
    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
      #トランザクションとは、指定したブロックにあるデータベースへの操作が全部成功することを保証する為の機能
      #ブロック内で例外処理が発生した場合にロールバックが発動する仕組み
      #何らかの原因で、勤怠データが期待通りに生成できずcreate!メソッドが例外を吐き出した時に、この繰り返し処理が始まる前の状態のデータベースに戻る
      
      # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
      one_month.each { |day| @user.attendances.create!(worked_on: day) }
      # createメソッドによってworked_onに日付の値が入ったAttendanceモデルのデータが生成されています
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
      #@attendancesの定義箇所を2箇所に増やしています。
      #これは実際に日付データを繰り返し処理で生成した後にも、正しく@attendances変数に値が代入されるようにするためです。
    end
    
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました。再アクセスしてください。"
    redirect_to root_url
  end
end
