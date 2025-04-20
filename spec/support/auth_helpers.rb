module AuthHelpers
  def auth_header_for(user)
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  def set_auth_header_for(user)
    @request.headers['Authorization'] = auth_header_for(user)['Authorization']
  end
end
