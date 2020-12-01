class AddChangeNoteToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_note, :string, comment: '変更後の内容'
  end
end
