module UsersHelper
  
  # 勤怠基本情報を指定のフォーマットで返します。
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
    # %は数値によって変化し、.2fは値がない場合は.00、値がある場合はそのまま、
    # 小数点第三位以上まである場合は第二位まで表示しそれ以降は切り捨てます
    #例えば基本情報として7時間30分を引数に渡されたとしましょう ((7 * 60) + 30) / 60.0
    #この計算結果としては7.5ですが、フォーマットとして指定した"%.2f"が7.50として返してくれます。
    #ちなみに計算式の最後の60.0にも意味があって、例えばこれを60としてしまうと整数同士の計算と判断されてしまい
    #上記の計算結果が7となってしまいます。
    #その場合7.00と表示されてしまうためこのような記述となっています
  end
end
