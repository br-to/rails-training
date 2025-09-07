module Authenticatable
  extend ActiveSupport::Concern

  private

  def authenticate_request!
    # トークン取得 → 検証 → ユーザー設定
    token = extract_token
    if valid_token?(token)
      # 一旦Userモデルは使用せず。認証成功として進む
      @current_user = { id: 1, name: "API User" } # 固定値
    else
      unauthorized!
    end
  end

  def extract_token
    # Bearer Token または X-API-Key
    request.headers['Authorization']&.gsub(/^Bearer /, '') ||
    request.headers['X-API-Key']
  end

  def valid_token?(token)
    # トークン検証ロジック
    token == 'your_secret_api_key_here' || token == 'admin_secret_key'
  end

  def check_permission!(required_role = :user)
    unless current_user_has_role?(required_role)
      forbidden!
      return
    end
  end

  def current_user_has_role?(role)
    token = extract_token
    case role
    when :admin
      token == 'admin_secret_key'
    else
      true # 通常ユーザー権限
    end
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
