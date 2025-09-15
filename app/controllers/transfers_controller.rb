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
        transfer = Transfer.create!(
          idempotency_key: idempotency_key,
          from_account_id: params[:from_account_id],
          to_account_id: params[:to_account_id],
          amount: params[:amount]
        )

        # 残高更新処理
        BalanceService.transfer(params[:from_account_id], params[:to_account_id], params[:amount])
        render json: { transfer: transfer, message: "Transfer completed" }
      end
    end
    rescue ActiveRecord::RecordInvalid => e
      render_unprocessable(e)
    rescue => e
      render_internal_error(e)
    end
  end

  private

  def transfer_params
    params.require(:transfer).permit(:from_account_id, :to_account_id, :amount)
  end
end
