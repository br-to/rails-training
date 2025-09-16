class TransfersController < ApplicationController
  def create
    # ヘッダーから冪等性キーを取得
    idempotency_key = request.headers['Idempotency-Key']
    return render_error('missing_idempotency_key', 400, 'Idempotency-Key header is required') unless idempotency_key

    # 冪等性の実装（Transaction内で実行）
    Transfer.transaction do
      transfer = Transfer.find_by(idempotency_key: idempotency_key)

      if transfer
        # 既存レコードあり → 前回と同じレスポンス（冪等性）
        render json: { transfer: transfer, message: "Transfer completed" }
      else
        # 新規作成 → 送金処理実行
        from_account_id = params[:from_account_id].to_i
        to_account_id = params[:to_account_id].to_i
        amount = params[:amount].to_i

        transfer = Transfer.create!(
          idempotency_key: idempotency_key,
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          amount: amount
        )

        # 残高更新処理
        BalanceService.transfer(from_account_id, to_account_id, amount)
        render json: { transfer: transfer, message: "Transfer completed" }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render_unprocessable(e)
  rescue BalanceService::InsufficientFundsError => e
    render_unprocessable(e)
  rescue => e
    render_internal_error(e)
  end

  private

  def transfer_params
    params.require(:transfer).permit(:from_account_id, :to_account_id, :amount)
  end
end
