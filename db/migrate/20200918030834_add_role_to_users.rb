class AddRoleToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :role, :string, default: 'employee', null: false, comment: '社員と上司区別'
  end
end
