class ChangeCheckStatusToString < ActiveRecord::Migration[7.2]
  def change
    change_column :repository_checks, :status, :string
  end
end
