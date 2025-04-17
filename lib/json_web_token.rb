require "jwt"

class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base
  SESSION_EXPIRATION_TIME = 7.days

  def self.encode(payload, exp = SESSION_EXPIRATION_TIME.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
