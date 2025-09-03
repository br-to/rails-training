require 'rails_helper'

RSpec.describe 'Articles API', type: :request do
  describe 'GET /articles' do
    it '公開条件を満たす記事のみを返す' do
      visible1 = FactoryBot.create(:article, published: true, published_at: nil)
      visible2 = FactoryBot.create(:article, published: true, published_at: 1.day.ago)
      _hidden1 = FactoryBot.create(:article, published: false)
      _hidden2 = FactoryBot.create(:article, published: true, published_at: 1.day.from_now)

      get '/articles'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      ids = json.map { |a| a['id'] }
      expect(ids).to contain_exactly(visible1.id, visible2.id)
    end
  end

  describe 'GET /articles/:id' do
    it '記事詳細を返す' do
      article = FactoryBot.create(:article, published: true)

      get "/articles/#{article.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(article.id)
      expect(json['title']).to eq(article.title)
    end

    it '存在しないIDなら404を返す' do
      get '/articles/999999'

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json.dig('error', 'code')).to eq('not_found')
    end
  end

  describe 'POST /articles' do
    it '記事を作成して201を返す' do
      params = {
        article: {
          title: 'New Title',
          body: 'Body',
          published: true,
          published_at: Time.current.iso8601
        }
      }

      post '/articles', params: params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['id']).to be_present
      expect(json['title']).to eq('New Title')
    end

    it '必須項目不足なら422を返す' do
      params = { article: { body: 'Only body' } } # title欠如

      post '/articles', params: params

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json.dig('error', 'code')).to eq('validation_error')
    end

    it 'パラメータルートが無ければ400を返す' do
      post '/articles', params: {}
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json.dig('error', 'code')).to eq('bad_request')
    end
  end

  describe 'PATCH /articles/:id' do
    it '記事を更新して200を返す' do
      article = FactoryBot.create(:article, published: false)
      params = { article: { published: true } }

      patch "/articles/#{article.id}", params: params

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['published']).to eq(true)
    end
  end

  describe 'DELETE /articles/:id' do
    it '記事を削除して204を返す' do
      article = FactoryBot.create(:article)

      delete "/articles/#{article.id}"

      expect(response).to have_http_status(:no_content)
      expect(Article.where(id: article.id)).to be_blank
    end
  end
end
