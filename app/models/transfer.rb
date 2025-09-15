class Transfer < ApplicationRecord
  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'

  validates :from_account_id, presence: true
  validates :to_account_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :idempotency_key, presence: true, uniqueness: true
end
