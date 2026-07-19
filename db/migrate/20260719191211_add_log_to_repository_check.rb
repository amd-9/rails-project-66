class AddLogToRepositoryCheck < ActiveRecord::Migration[8.1]
  def change
    add_column :repository_checks, :log, :text
  end
end
