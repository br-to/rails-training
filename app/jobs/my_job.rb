class MyJob < ApplicationJob
  queue_as :default

  # ActiveJob のリトライ設定（テスト環境以外）
  retry_on TemporaryExternalError, wait: 5.seconds, attempts: 5 unless Rails.env.test?
  discard_on PermanentExternalError unless Rails.env.test?

  def perform(action_type = "success")
    retry_count = executions - 1  # ActiveJob の executions メソッド
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
    Rails.logger.error(
      event: "job_error",
      job: self.class.name,
      job_id: job_id,
      error: e.class.name,
      error_message: e.message,
      permanent: true)
    raise # Deadキューに送るため
  end

  private

  def create_log_record(job_id, action_type)
    title = "Job Execution Log - #{job_id} - #{action_type}"

    Article.find_or_create_by(title: title) do |article|
      article.body = "This is a log entry for job #{job_id} with action #{action_type}."
      article.published = false
    end
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
