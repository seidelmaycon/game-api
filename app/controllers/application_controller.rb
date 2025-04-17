class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    return render_unauthorized unless token

    begin
      decoded = JsonWebToken.decode(token)
      @current_user = ::User.find(decoded[:user_id])
    rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
      @current_user = nil
    end

    render_unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def render_unauthorized
    render json: { errors: [ "Unauthorized" ] }, status: :unauthorized
  end
end
