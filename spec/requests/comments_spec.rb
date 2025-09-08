RSpec.describe 'Comments API', type: :request do
  describe 'POST /articles/:article_id/comments' do
    it 'コメントを作成して201を返す' do
      article = Article.create!(title: 'A for comment', body: 'b')
      params = { comment: { body: 'Hi', author: 'Alice' } }

      post "/articles/#{article.id}/comments", params: params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['id']).to be_present
      expect(json['body']).to eq('Hi')
    end

    it 'commentルートが無ければ400を返す' do
      article = Article.create!(title: 'A2 for comment', body: 'b')

      post "/articles/#{article.id}/comments", params: {}

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json.dig('error', 'code')).to eq('bad_request')
    end

    it '存在しない記事IDなら404を返す' do
      post '/articles/999999/comments', params: { comment: { body: 'x' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /articles/:article_id/comments/:id' do
    it 'コメントを更新して200を返す' do
      article = Article.create!(title: 'A3 for comment', body: 'b')
      comment = Comment.create!(article: article, body: 'old', author: 'x')

      patch "/articles/#{article.id}/comments/#{comment.id}", params: { comment: { body: 'new' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['body']).to eq('new')
    end

    it '存在しないコメントなら404を返す' do
      article = Article.create!(title: 'A4 for comment', body: 'b')
      patch "/articles/#{article.id}/comments/999999", params: { comment: { body: 'new' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /articles/:article_id/comments/:id' do
    it 'コメントを削除して204を返す' do
      article = Article.create!(title: 'A5 for comment', body: 'b')
      comment = Comment.create!(article: article, body: 'c', author: 'y')

      delete "/articles/#{article.id}/comments/#{comment.id}"

      expect(response).to have_http_status(:no_content)
      expect(Comment.where(id: comment.id)).to be_blank
    end
  end
end
