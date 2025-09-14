class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :balance, null: false, default: 0

      t.timestamps
    end

    add_check_constraint :accounts, "balance >= 0", name: "balance_non_negative"
  end
end
