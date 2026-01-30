# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AbandonedCartsJob, type: :job do
  let!(:active_cart) { Cart.create!(total_price: 10, last_interaction_at: 4.hours.ago, status: :active) }
  let!(:old_abandoned_cart) { Cart.create!(total_price: 20, last_interaction_at: 8.days.ago, status: :abandoned) }

  it 'marks inactive carts as abandoned' do
    AbandonedCartsJob.perform_now
    expect(active_cart.reload.status).to eq('abandoned')
  end

  it 'deletes abandoned carts older than 7 days' do
    expect { AbandonedCartsJob.perform_now }.to change { Cart.exists?(old_abandoned_cart.id) }.from(true).to(false)
  end
end
