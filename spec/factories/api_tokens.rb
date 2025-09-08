FactoryBot.define do
  factory :api_token do
    user
    token_digest { Digest::SHA256.hexdigest(SecureRandom.hex(32)) }
    revoked_at { nil }  # デフォルトは有効なトークン
    last_used_at { nil }

    trait :revoked do
      revoked_at { Time.current }
    end

    trait :used_recently do
      last_used_at { 1.hour.ago }
    end
  end
end
