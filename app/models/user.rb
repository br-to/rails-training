class User < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }

  has_many :api_tokens, dependent: :destroy

  # emailは小文字で保存
  before_save { self.email = email.downcase }
end
