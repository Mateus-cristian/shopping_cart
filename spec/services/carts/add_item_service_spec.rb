# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Carts::AddItemService, type: :service do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }

  it 'adds a new product to the cart' do
    service = described_class.new(cart:, product:, quantity: 2)
    result = service.call
    expect(result.cart_items.count).to eq(1)
    expect(result.cart_items.first.quantity).to eq(2)
    expect(result.total_price).to eq(20.0)
  end

  it 'raises error for invalid quantity' do
    service = described_class.new(cart:, product:, quantity: 0)
    expect { service.call }.to raise_error(ArgumentError)
  end

  it 'raises error for missing product' do
    expect { described_class.new(cart:, product: nil, quantity: 1) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
