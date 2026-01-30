# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Health API', type: :request do
  path '/health' do
    get('health check') do
      tags 'Health'
      produces 'application/json'
      response(200, 'healthy') do
        run_test!
      end
    end
  end
end
