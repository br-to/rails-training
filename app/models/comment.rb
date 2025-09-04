class Comment < ApplicationRecord
  belongs_to :article, counter_cache: true
end
