Rails.application.configure do
  if Rails.env.production? || Rails.env.development?
    config.lograge.enabled = true
    config.lograge.base_controller_class = 'ActionController::API'
    config.lograge.formatter = Lograge::Formatters::Json.new

    config.lograge.custom_options = lambda do |event|
      {
        request_id: event.payload[:request_id] || SecureRandom.uuid,
        time: Time.now.iso8601
      }
    end

    config.lograge.custom_payload do |controller|
      {
        params: controller.request.filtered_parameters.except('controller', 'action')
      }
    end
  end
end
