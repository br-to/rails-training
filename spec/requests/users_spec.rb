RSpec.describe "Users", type: :request do
  describe "GET /me" do
    let(:user) { create(:user) }

    context "認証なし" do
      it "401を返す" do
        get "/me"
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end

    context "無効なトークン" do
      it "401を返す" do
        get "/me", headers: { "Authorization" => "Bearer invalid_token" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end

    context "有効なトークン" do
      let(:plain_token) { ApiToken.generate_for(user) }

      it "200とユーザー情報を返す" do
        get "/me", headers: { "Authorization" => "Bearer #{plain_token}" }

        expect(response).to have_http_status(:ok)

        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('user_info')
        expect(response_body['user_info']['id']).to eq(user.id)
        expect(response_body['user_info']['name']).to eq(user.name)
        expect(response_body['user_info']['email']).to eq(user.email)
      end
    end

    context "失効済みトークン" do
      let(:api_token) do
        token = ApiToken.find_by_token(ApiToken.generate_for(user))
        token.revoke!
        token
      end

      it "401を返す" do
        plain_token = "token_#{api_token.id}.dummy_secret"
        get "/me", headers: { "Authorization" => "Bearer #{plain_token}" }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end
  end
end
