FactoryBot.define do
  factory :comment do
    article { nil }
    body { "MyText" }
    author { "MyString" }
  end
end
