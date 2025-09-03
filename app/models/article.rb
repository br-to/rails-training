class Article < ApplicationRecord
  has_many :comments, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :body, presence: true

  scope :published, -> { where(published: true) }
  scope :visible, -> { where(published: true).where("published_at IS NULL OR published_at <= ?", Time.current) }
end
