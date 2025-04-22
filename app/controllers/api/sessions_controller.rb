module Api
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!, only: :create
    before_action :set_user, only: :create

    def create
      if @user&.authenticate(session_params[:password])
        token = JsonWebToken.encode({ user_id: @user.id })
        render json: { token: token }, status: :created
      else
        render json: { errors: [ "Invalid email or password" ] }, status: :unauthorized
      end
    end

    private

    def set_user
      @user = ::User.find_by(email: session_params[:email])
    end

    def session_params
      params.permit(:email, :password)
    end
  end
end
