class ApiToken < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(revoked_at: nil) }

  def self.generate_for(user)
    # tok_#{id}.#{secret} 形式のトークン生成
    token = SecureRandom.hex(16)
    create!(token: "tok_#{user.id}.#{token}", user: user)
  end

  def revoke!
    # 失効処理
    update!(revoked_at: Time.current)
  end

  def active?
    # 有効性チェック
    revoked_at.nil?
  end
end
