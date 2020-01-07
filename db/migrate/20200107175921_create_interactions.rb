class CreateInteractions < ActiveRecord::Migration[5.1]
  def change
    create_table :interactions do |t|
      t.string :title
      t.string :answer_type
      t.boolean :active
      t.references :goal, foreign_key: true

      t.timestamps
    end
  end
end
