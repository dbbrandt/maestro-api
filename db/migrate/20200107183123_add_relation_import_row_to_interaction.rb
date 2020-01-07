class AddRelationImportRowToInteraction < ActiveRecord::Migration[5.1]
  def change
    add_reference :interactions, :import_row, foreign_key: true
  end
end
