RSpec.describe Article, type: :model do
  describe 'バリデーション' do
    it 'title, body が必須である' do
      article = Article.new
      expect(article).to be_invalid
      expect(article.errors[:title]).to be_present
      expect(article.errors[:body]).to be_present
    end

    it 'title は一意である' do
      Article.create!(title: 'dup', body: 'b')
      dup = Article.new(title: 'dup', body: 'b2')
      expect(dup).to be_invalid
      expect(dup.errors[:title]).to be_present
    end
  end

  describe 'スコープ' do
    it 'published は published:true のみ返す' do
      a1 = Article.create!(title: 'p1', body: 'b', published: true)
      _a2 = Article.create!(title: 'np1', body: 'b', published: false)
      expect(Article.published).to contain_exactly(a1)
    end

    it 'visible は公開中かつ公開日時が現在以前(またはnil)のみ返す' do
      v1 = Article.create!(title: 'v1', body: 'b', published: true, published_at: nil)
      v2 = Article.create!(title: 'v2', body: 'b', published: true, published_at: 1.minute.ago)
      _hidden1 = Article.create!(title: 'h1', body: 'b', published: false)
      _hidden2 = Article.create!(title: 'h2', body: 'b', published: true, published_at: 1.minute.from_now)
      expect(Article.visible).to contain_exactly(v1, v2)
    end
  end
end
