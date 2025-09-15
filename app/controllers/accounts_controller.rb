class AccountsController < ApplicationController
  def deposit
    amount = params[:amount].to_i

    # バリデーション
    return render_error("invalid_amount", "Amount must be positive") if amount <= 0

    begin
      account = BalanceService.deposit(params[:id], amount)
      render_success("Deposit completed", account)
    rescue ActiveRecord::RecordNotFound
      render_not_found
    rescue => e
      render_server_error(e)
    end
  end

  def withdraw
    amount = params[:amount].to_i

    # バリデーション
    return render_error("invalid_amount", "Amount must be positive") if amount <= 0

    begin
      account = BalanceService.withdraw(params[:id], amount)
      render_success("Withdraw completed", account)
    rescue BalanceService::InsufficientFundsError => e
      render_error("insufficient_funds", e.message)
    rescue ActiveRecord::RecordNotFound
      render_not_found
    rescue => e
      render_server_error(e)
    end
  end

  private

  def render_success(message, account)
    render json: {
      code: "success",
      message: message,
      data: {
        account_id: account.id,
        balance: account.balance
      }
    }, status: :ok
  end

  def render_error(code, message)
    render json: {
      code: code,
      message: message
    }, status: :unprocessable_entity
  end

  def render_not_found
    render json: {
      code: "not_found",
      message: "Account not found"
    }, status: :not_found
  end

  def render_server_error(error)
    Rails.logger.error("Unexpected error: #{error.message}")
    render json: {
      code: "internal_error",
      message: "Internal server error"
    }, status: :internal_server_error
  end
end
