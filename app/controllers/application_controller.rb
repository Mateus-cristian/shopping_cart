# frozen_string_literal: true

class ApplicationController < ActionController::API
  def health
    render json: { status: 'OK' }, status: :ok
  end
end
