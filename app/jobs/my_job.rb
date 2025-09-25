class MyJob < ApplicationJob
  queue_as :default

  # リトライ設定 5回まで
  sidekiq_options retry: 5

  # リトライ間隔のカスタマイズ
  sidekiq_retry_in do |count, exception|
    case exception
    when PermanentExternalError
      :kill # リトライしないで即座にDeadキューへ移動
    else
      15 * (count + 1) # 15秒、30秒、45秒、60秒、75秒
    end
  end

  def perform(action_type = "success")
    retry_count = sidekiq_options_hash["retry_count"] || 0
    start_time = Time.current
    job_id = self.job_id  # ActiveJob の job_id メソッド

    Rails.logger.info(
      event: "job_start",
      job: self.class.name,
      job_id: job_id,
      action_type: action_type,
    )

    create_log_record(job_id, action_type)

    simulate_external_api_call(action_type)

    duration = Time.current - start_time

    Rails.logger.info(
      event: "job_complete",
      job: self.class.name,
      job_id: job_id,
      action_type: action_type,
      duration: duration.round(3)
    )

  rescue TemporaryExternalError => e
    Rails.logger.error(
      event: "job_error",
      job: self.class.name,
      job_id: job_id,
      error: e.class.name,
      error_message: e.message,
      retry_count: retry_count
    )
    raise # Sidekiqが自動でリトライする
  rescue PermanentExternalError => e
    Rails.logger.error("Permanent error occurred: #{e.message}. Job will not be retried.")
    raise # Deadキューに送るため
  end

  private

  def create_log_record(job_id, action_type)
    title = "Job Execution Log - #{job_id} - #{action_type}"

    Article.find_or_create_by!(title: title) do |article|
      article.body = "This is a log entry for job #{job_id} with action #{action_type}."
      article.published = false
    end
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.info("Log record for job #{job_id} already exists, skipping creation.")
  end

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
