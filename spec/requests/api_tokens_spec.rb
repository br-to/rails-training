RSpec.describe "ApiTokens", type: :request do
  let(:user) { create(:user) }

  describe "POST /api_tokens" do
    context "有効なユーザーのemail" do
      it "201とトークンを返す" do
        post "/api_tokens", params: { user_email: user.email }

        expect(response).to have_http_status(:created)

        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('api_token')
        expect(response_body['api_token']).to start_with('token_')

        # トークンがDBに保存されていることを確認
        expect(user.api_tokens.active.count).to eq(1)
      end
    end

    context "存在しないemail" do
      it "404を返す" do
        post "/api_tokens", params: { email: "nonexistent@example.com" }

        expect(response).to have_http_status(:not_found)

        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('error')
      end
    end

    context "emailパラメータなし" do
      it "404を返す" do
        post "/api_tokens"

        expect(response).to have_http_status(:not_found)

        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('error')
      end
    end
  end

  describe "DELETE /api_tokens/:id" do
    let(:api_token) { create(:api_token, user: user) }
    let(:plain_token) { ApiToken.generate_for(user) }
    let(:token_to_delete) { ApiToken.find_by_token(plain_token) }

    context "有効なトークンで認証" do
      it "200とメッセージを返し、トークンを失効する" do
        delete "/api_tokens/#{token_to_delete.id}",
              headers: { "Authorization" => "Bearer #{plain_token}" }

        expect(response).to have_http_status(:ok)

        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('message')

        # トークンが失効していることを確認
        token_to_delete.reload
        expect(token_to_delete.active?).to be_falsey
      end
    end

    context "認証なし" do
      it "401を返す" do
        delete "/api_tokens/#{token_to_delete.id}"

        expect(response).to have_http_status(:unauthorized)

        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('error')
      end
    end

    context "無効なトークン" do
      it "401を返す" do
        delete "/api_tokens/#{token_to_delete.id}",
              headers: { "Authorization" => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)

        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('error')
      end
    end

    context "存在しないトークンID" do
      it "404を返す" do
        delete "/api_tokens/99999",
              headers: { "Authorization" => "Bearer #{plain_token}" }

        expect(response).to have_http_status(:not_found)

        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('error')
      end
    end
  end
end
