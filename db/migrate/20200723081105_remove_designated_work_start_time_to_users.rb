class RemoveDesignatedWorkStartTimeToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :designated_work_start_time, :datetime
  end
end
