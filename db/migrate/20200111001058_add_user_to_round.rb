class AddUserToRound < ActiveRecord::Migration[5.1]
  def change
    add_reference :rounds, :user, foreign_key: true
  end
end
