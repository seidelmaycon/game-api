class BillingService
  attr_reader :base_url, :api_key

  EXPECTED_STATUS = [ "active", "expired" ].freeze
  FALLBACK_STATUS = "unknown".freeze
  NOT_FOUND_STATUS = "not_found".freeze

  Result = Struct.new(:status)

  def initialize(base_url: nil, api_key: nil)
    @base_url = base_url || Rails.application.credentials.billing_api[:base_url]
    @api_key = api_key || Rails.application.credentials.billing_api[:key]
  end

  def get_subscription_status(user_id)
    response = conn.get("users/#{user_id}/billing")

    if response.success?
      data = JSON.parse(response.body)
      if data.key?("subscription_status") && EXPECTED_STATUS.include?(data["subscription_status"])
        Result.new(data["subscription_status"])
      else
        Rails.logger.error("BillingService error: Invalid subscription status: #{data["subscription_status"]}")
        Result.new(FALLBACK_STATUS)
      end
    elsif response.status == 404
      Rails.logger.info("BillingService: User #{user_id} not found")
      Result.new(NOT_FOUND_STATUS)
    else
      Rails.logger.error("BillingService error: #{response.status} #{response.body}")
      Result.new(FALLBACK_STATUS)
    end
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error("BillingService error: #{e.message}")
    Result.new(FALLBACK_STATUS)
  end

  private

  def conn
    @conn ||= Faraday.new(url: base_url) do |conn|
      conn.headers["Authorization"] = api_key
      conn.headers["Content-Type"] = "application/json"
      conn.options.timeout = 5
      conn.options.open_timeout = 3
      conn.adapter Faraday.default_adapter
    end
  end
end
