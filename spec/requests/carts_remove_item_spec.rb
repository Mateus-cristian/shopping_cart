# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DELETE /cart/:product_id', type: :request do
  let!(:cart) { Cart.create!(total_price: 0) }
  let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
  let!(:product2) { Product.create!(name: 'Produto Y', price: 9.9) }

  before do
    cart.cart_items.create!(product: product1, quantity: 2, unit_price: 7.0)
    cart.cart_items.create!(product: product2, quantity: 1, unit_price: 9.9)
    post '/cart/rack_session', params: { cart_id: cart.id }
  end

  it 'removes a product from the cart and returns updated payload' do
    delete "/cart/#{product1.id}"
    expect(response).to have_http_status(:ok)
    json = response.parsed_body
    expect(json['products'].size).to eq(1)
    expect(json['products'][0]['id']).to eq(product2.id)
    expect(json['total_price']).to eq(9.9)
  end

  it 'returns error if product is not in the cart' do
    delete '/cart/9999'
    expect(response).to have_http_status(404)
    json = response.parsed_body
    expect(json['error']).to eq('Produto não encontrado')
  end

  it 'handles empty cart after removal' do
    delete "/cart/#{product1.id}"
    delete "/cart/#{product2.id}"
    expect(response).to have_http_status(:ok)
    json = response.parsed_body
    expect(json['products']).to eq([])
    expect(json['total_price']).to eq(0.0)
  end

  it 'returns error when the cart is missing from the session' do
    post '/cart/rack_session', params: { cart_id: nil }
    delete "/cart/#{product1.id}"
    expect(response).to have_http_status(404)
    json = response.parsed_body
    expect(json['error']).to eq('Carrinho não encontrado')
  end
end
