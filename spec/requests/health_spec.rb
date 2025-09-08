RSpec.describe 'Health Check', type: :request do
  describe 'GET /health' do
    it 'returns a successful response' do
      get '/health'

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(a_string_including('application/json'))
    end

    it 'returns the correct JSON structure' do
      get '/health'

      json_response = JSON.parse(response.body)

      expect(json_response).to include(
        'status' => 'ok',
        'timestamp' => be_a(String),
        'version' => be_a(String),
        'services' => be_a(Hash)
      )

      expect(json_response['services']).to include(
        'database' => be_a(String),
        'redis' => be_a(String)
      )
    end
  end
end
