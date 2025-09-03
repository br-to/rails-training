FactoryBot.define do
  factory :comment do
    association :article
    body { "Sample comment" }
    author { "Commenter" }
  end
end
