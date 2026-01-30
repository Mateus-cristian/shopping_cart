# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /cart', type: :request do
  let!(:cart) { Cart.create!(total_price: 0) }
  let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
  let!(:product2) { Product.create!(name: 'Produto Y', price: 9.9) }

  before do
    cart.cart_items.create!(product: product1, quantity: 2, unit_price: 7.0)
    cart.cart_items.create!(product: product2, quantity: 1, unit_price: 9.9)
    cart.update!(total_price: cart.cart_items.sum { |item| item.unit_price * item.quantity })
    post '/cart/rack_session', params: { cart_id: cart.id }
  end

  it 'returns the current cart with products' do
    get '/cart'
    expect(response).to have_http_status(200)
    json = response.parsed_body
    expect(json['id']).to eq(cart.id)
    expect(json['products'].size).to eq(2)
    expect(json['products'][0]['id']).to eq(product1.id)
    expect(json['products'][0]['name']).to eq('Produto X')
    expect(json['products'][0]['quantity']).to eq(2)
    expect(json['products'][0]['unit_price']).to eq(7.0)
    expect(json['products'][0]['total_price']).to eq(14.0)
    expect(json['products'][1]['id']).to eq(product2.id)
    expect(json['products'][1]['name']).to eq('Produto Y')
    expect(json['products'][1]['quantity']).to eq(1)
    expect(json['products'][1]['unit_price']).to eq(9.9)
    expect(json['products'][1]['total_price']).to eq(9.9)
    expect(json['total_price']).to eq(23.9)
  end

  it 'returns error when the cart is missing from the session' do
    post '/cart/rack_session', params: { cart_id: nil }
    get '/cart'
    expect(response).to have_http_status(404)
    json = response.parsed_body
    expect(json['error']).to eq('Carrinho não encontrado')
  end
end
