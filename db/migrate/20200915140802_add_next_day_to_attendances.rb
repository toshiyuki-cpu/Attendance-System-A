class AddNextDayToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :next_day, :boolean, comment: '日をまたぐ計算'
  end
end
