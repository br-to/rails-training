class ExternalApiError < StandardError
  attr_reader :status_code, :response_body, :original_error
  # 共通的な属性やメソッドを定義
  def initialize(message = nil, status_code = nil, response_body = nil, original_error = nil)
    super(message || "External API error")
    @status_code = status_code
    @response_body = response_body
    @original_error = original_error
  end

end
