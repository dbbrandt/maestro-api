class CreateImportRows < ActiveRecord::Migration[5.1]
  def change
    create_table :import_rows do |t|
      t.string :title
      t.string :json_data
      t.references :import_file, foreign_key: true

      t.timestamps
    end
  end
end
