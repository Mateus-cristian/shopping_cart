# frozen_string_literal: true

class RackSessionController < ApplicationController
  def create
    session[:cart_id] = params[:cart_id]
    head :ok
  end
end
