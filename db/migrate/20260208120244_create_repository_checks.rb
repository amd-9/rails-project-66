class CreateRepositoryChecks < ActiveRecord::Migration[7.2]
  def change
    create_table :repository_checks do |t|
      t.string :commit_id
      t.integer :status
      t.boolean :passed
      t.belongs_to :repository, null: false, foreign_key: true

      t.timestamps
    end
  end
end
