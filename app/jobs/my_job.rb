class MyJob < ApplicationJob
  queue_as :default

  def perform(action_type = "success")
    simulate_external_api_call(action_type)
    Rails.logger.info("Job completed successfully")
  rescue TemporaryExternalError => e
    Rails.logger.error("Temporary error occurred: #{e.message}")
    raise # Sidekiqが自動でリトライする
  rescue PermanentExternalError => e
    Rails.logger.error("Permanent error occurred: #{e.message}. Job will not be retried.")
    raise # Deadキューに送るため
  end

  private

  # 外部API呼び出しをシミュレート
  def simulate_external_api_call(action_type)
    case action_type
    when "temporary_failure"
      raise TemporaryExternalError.new("API timeout")
    when "permanent_failure"
      raise PermanentExternalError.new("Invalid request")
    end
  end
end
