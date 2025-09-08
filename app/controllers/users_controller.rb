class UsersController < ApplicationController
  include Authenticatable
  before_action :authenticate_request!

  def me
    render json: {
      message: "ログインしました",
      user_info: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email
      }
    }
  end

  def admin_info
    check_permission!(:admin)
    return if performed? # レンダリング済みの場合は早期リターン

    render json: {
      message: "Admin only data",
      admin_info: {
        total_users: 100,
        system_status: "healthy"
      }
    }
  end
end
