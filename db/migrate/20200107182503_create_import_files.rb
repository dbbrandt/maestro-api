class CreateImportFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :import_files do |t|
      t.string :title
      t.string :json_data
      t.references :goal, foreign_key: true

      t.timestamps
    end
  end
end
