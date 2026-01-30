# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /cart/add_item', type: :request do
  let!(:cart) { Cart.create!(total_price: 0) }
  let!(:product) { Product.create!(name: 'Test Product', price: 10.0) }
  let!(:cart_item) { CartItem.create!(cart:, product:, quantity: 1, unit_price: product.price) }

  before do
    post '/cart/rack_session', params: { cart_id: cart.id }
  end

  it 'updates the quantity of the existing item in the cart' do
    post '/cart/add_item', params: { product_id: product.id, quantity: 1 }
    post '/cart/add_item', params: { product_id: product.id, quantity: 1 }
    expect(cart_item.reload.quantity).to eq(3)
  end
end
