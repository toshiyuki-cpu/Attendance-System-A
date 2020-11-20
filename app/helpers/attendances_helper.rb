module AttendancesHelper
 # このメソッドを使って勤怠登録ボタンのテキストには何が必要か？または必要ないか？をこのメソッドで判定すること 
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    # このメソッドでは戻り値が3パターンある
    # このメソッドの戻り値と、if文のルールを使ってビューを制御。
    # if文は条件式の結果がtrueなら処理を実行しfalseなら何もしない
   
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
       # 上記の3つの戻り値のうち、'出勤'と'退勤'はtrueとして判断されます
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
      # 追加したworking_timesメソッドでは、2つの引数を設定しています。
      # そして、受け取った引数��使って時間の計算処理をして値を返す仕組み
  end
  
  # 時間外時間（残業申請）
  def hours_of_overtime(next_day, end_time, end_plan)
    if next_day # ifの条件はbooleanが必要。next_dayにはbooleanがはいってる
      format("%.2f", (24 + end_plan.hour) - end_time.hour + (end_plan.min - end_time.min) / 60.00) 
    else
      format("%.2f", (end_plan.hour - end_time.hour) + (end_plan.min - end_time.min) / 60.00)
    end
  end
  
  # 時間外時間（勤怠変更申請）
  def edit_hours_of_overtime(edit_next_day, end_time, end_plan)
    if next_day # ifの条件はbooleanが必要。next_dayにはbooleanがはいってる
      format("%.2f", (24 + end_plan.hour) - end_time.hour + (end_plan.min - end_time.min) / 60.00) 
    else
      format("%.2f", (end_plan.hour - end_time.hour) + (end_plan.min - end_time.min) / 60.00)
    end
  end
  
  # 指示者確認欄の表示設定
  def overtime_reply_text(attendance)
    case attendance.overtime_status
    when 'applying'
        "#{attendance.superior.name}に残業申請中"
    when 'approval'
        "#{attendance.superior.name}から残業承認済"
    when 'negation'
        "#{attendance.superior.name}から残業否認されました"
    when 'cancel'
        "#{attendance.superior.name}から残業キャンセルされました"
    end
  end
end  
  # Attendances Helperにより下記のshow.html.erbの記述はいらなくなる
  #	<% if (Date.current == day.worked_on) && day.started_at.nil? %>
  #	<!--繰り返し処理中の日付と、実際の日付における当日が一致することを条件とし、さらに該当する日付データにはstarted_atがnilであるか？
  #	を評価しています。どちらもtrueとなる時のみ、ボタンの出力部分が実行されます-->
  #	<%= link_to "出社", user_attendance_path(@user, day), method: :patch, class: "btn btn-primary btn-attendance" %>
  #	<% elsif (Date.current == day.worked_on) && day.started_at.present? day.finished_at.nil? %>
  #	<%= link_to "退社", user_attendance_path(@user, day), method: :patch, class: "btn btn-primary btn-attendance" %>
  #	<% end %>