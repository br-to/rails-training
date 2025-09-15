class BalanceService
  class InsufficientFundsError < StandardError; end

  # 入金
  def self.deposit(account_id, amount)
    # トランザクション内で実行
    Account.transaction do
      account = Account.lock.find(account_id)
      account.balance += amount
      account.save!

      Rails.logger.info("event=balance_update account_id=#{account_id} delta=+#{amount} result=ok reason=deposit")
      account
    end
  rescue => e
    # エラーログ
    Rails.logger.info("event=balance_update account_id=#{account_id} delta=+#{amount} result=error reason=#{e.class.name}")
    raise
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

      Rails.logger.info("event=balance_update account_id=#{account_id} delta=-#{amount} result=ok reason=withdraw")
      account
    end
  rescue InsufficientFundsError => e
    Rails.logger.info("event=balance_update account_id=#{account_id} delta=-#{amount} result=error reason=insufficient_funds")
    raise
  rescue => e
    # システムエラーログ
    Rails.logger.info("event=balance_update account_id=#{account_id} delta=-#{amount} result=error reason=#{e.class.name}")
    raise
  end

  def self.transfer(from_account_id, to_account_id, amount)
    # トランザクション内で実行
    Account.transaction do
      from_account = Account.lock.find(from_account_id)
      to_account = Account.lock.find(to_account_id)

      if from_account.balance < amount
        raise InsufficientFundsError, "Insufficient funds in account #{from_account_id}"
      end

      from_account.balance -= amount
      to_account.balance += amount

      from_account.save!
      to_account.save!

      Rails.logger.info("event=balance_transfer from_account_id=#{from_account_id} to_account_id=#{to_account_id} amount=#{amount} result=ok")
      true
    end
  rescue InsufficientFundsError => e
    Rails.logger.info("event=balance_transfer from_account_id=#{from_account_id} to_account_id=#{to_account_id} amount=#{amount} result=error reason=insufficient_funds")
    raise
  rescue => e
    # システムエラーログ
    Rails.logger.info("event=balance_transfer from_account_id=#{from_account_id} to_account_id=#{to_account_id} amount=#{amount} result=error reason=#{e.class.name}")
    raise
  end
end
