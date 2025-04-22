module Api
  class UserController < ApplicationController
    skip_before_action :authenticate_user!, only: :create
    before_action :validate_params, only: :create

    def show
      render json: current_user, context: { subscription_status: subscription_status }
    end

    def create
      user = ::User.new(user_params)
      if user.save
        render json: { message: "User created successfully" }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def subscription_status
      result = BillingService.new.get_subscription_status(current_user.id)
      result.status
    end

    def user_params
      params.permit(:email, :password)
    end

    def validate_params
      return if user_params[:email].present? && user_params[:password].present?

      render json: { errors: [ "Email and password are required" ] }, status: :bad_request
    end
  end
end
