class TemporaryExternalError < ExternalApiError
  # 一時的な失敗（タイムアウト、ネットワークエラー、5xxエラーなど）
  # Sidekiqが自動でリトライする
  def initialize(message = nil, status_code = nil, response_body = nil, original_error = nil)
    super(message || "Temporary external API error", status_code, response_body, original_error)
  end
end
