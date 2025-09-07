FactoryBot.define do
  factory :api_token do
    user { nil }
    token_digest { "MyString" }
    revoked_at { "2025-09-07 16:37:56" }
    last_used_at { "2025-09-07 16:37:56" }
  end
end
