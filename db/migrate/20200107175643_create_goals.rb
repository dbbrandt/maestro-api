class CreateGoals < ActiveRecord::Migration[5.1]
  def change
    create_table :goals do |t|
      t.string :title
      t.string :description
      t.string :instructions
      t.string :image_url
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
