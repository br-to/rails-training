require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '関連' do
    it 'article に必ず属する（必須）' do
      comment = Comment.new(body: 'x', author: 'y')
      expect(comment).to be_invalid
      expect(comment.errors[:article]).to be_present
    end

    it 'article の削除で一緒に削除される（dependent: :destroy）' do
      article = Article.create!(title: 'with comment', body: 'b')
      comment = article.comments.create!(body: 'c', author: 'a')
      expect { article.destroy! }.to change { Comment.where(id: comment.id).exists? }.from(true).to(false)
    end

    it 'counter_cache が増減する' do
      article = Article.create!(title: 'cc', body: 'b')
      expect(article.comments_count).to eq(0)
      article.comments.create!(body: 'c', author: 'a')
      expect(article.reload.comments_count).to eq(1)
    end
  end
end
