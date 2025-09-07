require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /me" do
    context "認証なし" do
      it "401を返す" do
        get "/me"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "正しい認証" do
      it "200を返す" do
        get "/me", headers: { "X-API-Key" => "your_secret_api_key_here" }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /admin" do
    it "権限不足で403を返す" do
      get "/admin", headers: { "X-API-Key" => "your_secret_api_key_here" }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
