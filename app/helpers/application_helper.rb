module ApplicationHelper
  # full_titleヘルパーメソッド
  def full_title(page_name = '')
    base_title = 'AttendanceApp'
    if page_name.empty? # 引数を受け取っているか判定
      base_title
    else
      page_name + ' | ' + base_title
    end
  end
end
