class BalanceService
  class InsufficientFundsError < StandardError; end

  # 入金
  def self.deposit(account_id, amount)
    # トランザクション内で実行
    Account.transaction do
      account = Account.lock.find(account_id)
      account.balance += amount
      account.save!
      account  # ← これを追加して戻り値を統一
    end
  end

  # 出金
  def self.withdraw(account_id, amount)
    # トランザクション内で実行
    Account.transaction do
      account = Account.lock.find(account_id)

      if account.balance < amount
        raise InsufficientFundsError, "Insufficient funds in account #{account_id}"
      end

      account.balance -= amount
      account.save!
      account
    end
  rescue InsufficientFundsError => e
    Rails.logger.info("event=balance_update account_id=#{account_id} delta=-#{amount} result=error reason=insufficient_funds")
    raise # 再発生させてコントローラーで422を返す
  end
end
