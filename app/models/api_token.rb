class ApiToken < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(revoked_at: nil) }

  def self.generate_for(user)
    # token_#{id}.#{secret} 形式のトークン生成
    secret = SecureRandom.hex(32)
    digest = Digest::SHA256.hexdigest(secret)

    # レコード作成
    api_token = create!(user: user, token_digest: digest)

    # 作成後にplain_tokenを組み立て
    plain_token = "token_#{api_token.id}.#{secret}"

    plain_token
  end

  def self.find_by_token(plain_token)
    # token_#{id}.#{secret} 形式のトークンからIDを抽出
    match = plain_token.match(/\Atoken_(\d+)\.(.+)\z/)
    return nil unless match

    id = match[1].to_i
    secret = match[2]

    # IDとシークレットからトークンを検索
    find_by(id: id, token_digest: Digest::SHA256.hexdigest(secret))
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
