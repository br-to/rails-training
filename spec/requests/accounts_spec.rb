RSpec.describe "Accounts API", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@example.com") }
  let(:account) { Account.create!(user: user, balance: 1000) }

  describe "POST /accounts/:id/withdraw" do
    context "when insufficient funds" do
      it "returns 422 with error format" do
        post "/accounts/#{account.id}/withdraw", params: { amount: 1500 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to match({
          "code" => "insufficient_funds",
          "message" => String
        })
      end
    end

    context "when account not found" do
      it "returns 404 with error format" do
        post "/accounts/99999/withdraw", params: { amount: 100 }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to match({
          "code" => "not_found",
          "message" => "Account not found"
        })
      end
    end
  end
end
