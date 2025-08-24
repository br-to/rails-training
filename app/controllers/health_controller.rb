class HealthController < ApplicationController
  # GET /health
  def index
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: '1.0.0',
      services: {
        database: database_status,
        redis: redis_status
      }
    }, status: :ok
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue StandardError => e
    Rails.logger.error "Database health check failed: #{e.message}"
    'disconnected'
  end

  def redis_status
    Redis.current.ping == 'PONG' ? 'connected' : 'disconnected'
  rescue StandardError => e
    Rails.logger.error "Redis health check failed: #{e.message}"
    'disconnected'
  end
end
