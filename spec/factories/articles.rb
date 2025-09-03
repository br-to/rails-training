FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article #{n}" }
    body { "Sample body text" }
    published { false }
    published_at { nil }
  end
end
