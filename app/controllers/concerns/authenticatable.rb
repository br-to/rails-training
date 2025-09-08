module Authenticatable
  extend ActiveSupport::Concern

  private

  def authenticate_request!
    # トークン取得 → 検証 → ユーザー設定
    token = extract_token
    api_token = ApiToken.find_by_token(token) if token
    if api_token && api_token.active?
      @current_user = api_token.user
      api_token.touch(:last_used_at)
    else
      unauthorized!
    end
  end

  def extract_token
    # Bearer Token または X-API-Key
    request.headers['Authorization']&.gsub(/^Bearer /, '') ||
    request.headers['X-API-Key']
  end

  def check_permission!(required_role = :user)
    unless current_user_has_role?(required_role)
      forbidden!
      return
    end
  end

  # シンプルにする（今回の要件では管理者権限は非スコープ）
  def current_user_has_role?(role)
    true  # 認証済みユーザーは全て同じ権限
  end

  def current_user
    # 認証済みユーザー
    @current_user
  end

  def unauthorized!
    # 401レスポンス
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def forbidden!
    # 403レスポンス
    render json: { error: 'Forbidden' }, status: :forbidden
  end
end
