class AddChangeFinishedAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_finished_at, :datetime, comment: '変更後の退社時間'
  end
end
