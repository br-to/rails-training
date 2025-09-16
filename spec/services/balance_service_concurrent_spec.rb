RSpec.describe BalanceService, type: :service do
  let(:user) { User.create!(name: "Test User", email: "test@example.com") }
  let(:account) { Account.create!(user: user, balance: 1000) }

  describe ".deposit" do
    it "deposits amount correctly under concurrency" do
      threads = []
      10.times do
        threads << Thread.new do
          BalanceService.deposit(account.id, 100)
        end
      end
      threads.each(&:join)

      account.reload
      expect(account.balance).to eq(2000)
    end
  end

  describe ".withdraw" do
    context "when sufficient funds" do
      it "withdraws amount correctly under concurrency" do
        threads = []
        5.times do
          threads << Thread.new do
            BalanceService.withdraw(account.id, 100)
          end
        end
        threads.each(&:join)

        account.reload
        expect(account.balance).to eq(500)
      end
    end

    context "when insufficient funds" do
      it "raises InsufficientFundsError under concurrency" do
        threads = []
        errors = Queue.new

        15.times do
          threads << Thread.new do
            begin
              BalanceService.withdraw(account.id, 100)
            rescue BalanceService::InsufficientFundsError => e
              errors << e.message
            end
          end
        end
        threads.each(&:join)

        account.reload
        expect(account.balance).to be >= 0
        expect(errors.size).to be >= 5 # 少なくとも5回は失敗するはず
      end
    end
  end
end
