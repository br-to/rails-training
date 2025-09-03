class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid,     with: :render_unprocessable
  rescue_from ActiveRecord::RecordNotUnique,   with: :render_conflict
  rescue_from ActiveRecord::InvalidForeignKey, with: :render_unprocessable
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from JSON::ParserError,               with: :render_bad_request
  rescue_from ActionController::UnpermittedParameters, with: :render_bad_request

  # 本番では500も握ってリーク防止（開発では落としてスタックを見る）
  rescue_from StandardError, with: :render_internal_error unless Rails.env.development? || Rails.env.test?

  private

  # 404 Not Found
  def render_not_found(e)
    render_error('not_found', 404, e.message)
  end

  # 422 Unprocessable Entity
  def render_unprocessable(e)
    details =
      if e.respond_to?(:record) && e.record
        e.record.errors.full_messages
      else
        [e.message]
      end
    render_error('validation_error', 422, 'Validation failed', details: details)
  end

  # 409 Conflict
  def render_conflict(e)
    render_error('conflict', 409, 'Conflict', details: [e.message])
  end

  # 400 Bad Request
  def render_bad_request(e)
    render_error('bad_request', 400, e.message)
  end

  # 500 Internal Server Error
  def render_internal_error(e)
    Rails.logger.error("[500] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
    render_error('internal_error', 500, 'Internal Server Error')
  end

  # 共通エラーレスポンス
  def render_error(code, status, message, details: nil)
    payload = { error: { code: code, message: message, request_id: request.request_id } }
    payload[:error][:details] = details if details
    render json: payload, status: status
  end
end
