RSpec.describe "Transfers", type: :request do
  let(:user1) { User.create!(name: "User One", email: "test1@example.com") }
  let(:user2) { User.create!(name: "User Two", email: "test2@example.com") }
  let(:account1) { Account.create!(user: user1, balance: 5000) }
  let(:account2) { Account.create!(user: user2, balance: 1000) }
  let(:headers) { { "Idempotency-Key" => SecureRandom.uuid } }
  let(:params) { { from_account_id: account1.id, to_account_id: account2.id, amount: 1000 } }

  describe "POST /transfers" do
    context "初回送金成功" do
      it "returns 200 and creates a transfer" do
        post "/transfers", params: params, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include("message" => "Transfer completed")

        # 残高確認
        expect(account1.reload.balance).to eq(4000)
        expect(account2.reload.balance).to eq(2000)
      end
    end

    context "冪等性キーが同じ場合" do
      it "returns the same response without duplicating the transfer" do
        # 初回送金
        post "/transfers", params: params, headers: headers
        first_response = response.parsed_body

        # 再度同じ冪等性キーで送金
        post "/transfers", params: params, headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq(first_response)

        # 残高が変わっていないことを確認
        expect(account1.reload.balance).to eq(4000)
        expect(account2.reload.balance).to eq(2000)
      end
    end

    context "残高不足の場合" do
      it "returns 422 error" do
        insufficient_params = params.merge(amount: 10000) # 残高5000より多い

        post "/transfers", params: insufficient_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        # 残高は変わらない
        expect(account1.reload.balance).to eq(5000)
        expect(account2.reload.balance).to eq(1000)
      end
    end

    context "Idempotency-Keyが不足の場合" do
      it "returns 400 error" do
        post "/transfers", params: params  # headersなし

        expect(response).to have_http_status(:bad_request)
      end
    end

    context "並行リクエストのテスト" do
      it "並行100リクエストでも二重計上されない" do
        # 各リクエスト用の初期残高を大きく設定
        account1.update!(balance: 100_000)

        threads = []
        results = []

        100.times do |i|
          threads << Thread.new do
            headers = { "Idempotency-Key" => "concurrent-test-#{i}" }
            post "/transfers", params: params, headers: headers
            results << response.status
          end
        end

        threads.each(&:join)

        expect(results.count(200)).to eq(100)  # 全て成功
        expect(account1.reload.balance).to eq(100_000 - (1000 * 100))  # 正確な残高: 0
        expect(account2.reload.balance).to eq(1000 + (1000 * 100))     # 正確な残高: 101,000
      end
    end
  end
end
