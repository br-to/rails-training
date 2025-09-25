class PermanentExternalError < ExternalApiError
  # 恒久的な失敗（4xxエラー、バリデーションエラーなど）
  # Sidekiqはリトライせず、即座にDeadキューへ移動する
  def initialize(message = nil, status_code = nil, response_body = nil, original_error = nil)
    super(message || "Permanent external API error", status_code, response_body, original_error)
  end
end
