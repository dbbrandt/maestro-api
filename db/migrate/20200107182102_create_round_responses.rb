class CreateRoundResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :round_responses do |t|
      t.string :answer
      t.float :score
      t.boolean :is_corrects
      t.boolean :review_is_correct
      t.string :descriptor
      t.references :round, foreign_key: true
      t.references :interaction, foreign_key: true

      t.timestamps
    end
  end
end
