class ApiTokensController < ApplicationController
  include Authenticatable
  before_action :authenticate_request!, except: [:create]

  def create
    user = User.find_by(email: params[:user_email])
      return render json: { error: 'User not found' }, status: :not_found unless user

    plain_token = ApiToken.generate_for(user)
    render json: { api_token: plain_token }, status: :created
  end

  def destroy
    # トークン失効（認証済みユーザー向け）
    check_permission!(:user)

    # URLのIDパラメータを使用し、current_userのトークンのみ削除可能
    api_token = current_user.api_tokens.find_by(id: params[:id])
    if api_token
      api_token.revoke!
      render json: { message: 'Token revoked' }, status: :ok
    else
      render json: { error: 'Token not found' }, status: :not_found
    end
  end
end
