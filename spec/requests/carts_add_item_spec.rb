# frozen_string_literal: true

require 'rails_helper'

describe 'POST /cart/add_item', type: :request do
  let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
  let!(:product2) { Product.create!(name: 'Produto Y', price: 9.9) }
  let!(:cart) { Cart.create!(total_price: 0) }

  before do
    cart.cart_items.create!(product: product1, quantity: 2, unit_price: 7.0)
    cart.cart_items.create!(product: product2, quantity: 1, unit_price: 9.9)
    post '/cart/rack_session', params: { cart_id: cart.id }
  end

  it 'updates the quantity of an existing product in the cart' do
    post '/cart/add_item', params: { product_id: product1.id, quantity: 5 }
    expect(response).to have_http_status(:ok)
    json = response.parsed_body
    expect(json['products'].size).to eq(2)
    expect(json['products'][0]['id']).to eq(product1.id)
    expect(json['products'][0]['quantity']).to eq(7)
    expect(json['products'][1]['id']).to eq(product2.id)
    expect(json['products'][1]['quantity']).to eq(1)
  end

  it 'adds a new product to the cart if not present' do
    product3 = Product.create!(name: 'Produto Z', price: 5.5)
    post '/cart/add_item', params: { product_id: product3.id, quantity: 2 }
    expect(response).to have_http_status(:ok)
    json = response.parsed_body
    expect(json['products'].size).to eq(3)
    expect(json['products'].pluck('id')).to include(product3.id)
  end

  it 'returns error for invalid quantity' do
    post '/cart/add_item', params: { product_id: product1.id, quantity: 0 }
    expect(response).to have_http_status(422)
    json = response.parsed_body
    expect(json['error']).to eq('Quantidade deve ser maior que zero')
  end

  it 'returns error for missing product' do
    post '/cart/add_item', params: { product_id: 9999, quantity: 1 }
    expect(response).to have_http_status(404)
    json = response.parsed_body
    expect(json['error']).to eq('Produto não encontrado')
  end
end
