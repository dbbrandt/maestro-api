class CreateContents < ActiveRecord::Migration[5.1]
  def change
    create_table :contents do |t|
      t.string :title
      t.string :content_type
      t.string :description
      t.string :stimulus_url
      t.string :copy
      t.float :score
      t.string :descriptor
      t.references :interaction, foreign_key: true

      t.timestamps
    end
  end
end
