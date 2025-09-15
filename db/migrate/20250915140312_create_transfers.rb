class CreateTransfers < ActiveRecord::Migration[7.2]
  def change
    create_table :transfers do |t|
      t.bigint :from_account_id, null: false      # 外部キー（Accountテーブルのid）
      t.bigint :to_account_id, null: false        # 外部キー（Accountテーブルのid）
      t.integer :amount, null: false              # 送金額（整数、単位は cents など）
      t.string :idempotency_key, null: false     # 冪等性キー（文字列）

      t.timestamps                                # created_at, updated_at（自動）
    end

    # インデックスと制約
    add_index :transfers, :idempotency_key, unique: true
    add_foreign_key :transfers, :accounts, column: :from_account_id
    add_foreign_key :transfers, :accounts, column: :to_account_id
  end
end
