# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Cart API', type: :request do
  path '/carts' do
    get('Get current cart') do
      tags 'Cart'
      produces 'application/json'

      response(200, 'successful') do
        let!(:cart) { Cart.create!(total_price: 0) }
        let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
        let!(:product2) { Product.create!(name: 'Produto Y', price: 9.9) }

        before do
          cart.cart_items.create!(product: product1, quantity: 2, unit_price: 7.0)
          cart.cart_items.create!(product: product2, quantity: 1, unit_price: 9.9)
          post '/rack_session', params: { cart_id: cart.id }
        end

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
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
      end
    end

    post('Add product to cart') do
      tags 'Cart'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer },
          quantity: { type: :integer }
        },
        required: %w[product_id quantity]
      }

      response(200, 'Product added to cart') do
        let!(:cart) { create(:cart, total_price: 0) }
        let!(:product) { create(:product, name: 'Test Product', price: 1.99) }

        before do
          post '/rack_session', params: { cart_id: cart.id }
        end

        let(:body) { { product_id: product.id, quantity: 2 } }

        run_test! do |response|
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(JSON.parse(response.body)['id']).to be_a(Integer)
        end
      end

      response(404, 'Product not found') do
        let!(:cart) { create(:cart, total_price: 0) }
        before { post '/rack_session', params: { cart_id: cart.id } }
        let(:body) { { product_id: 9999, quantity: 2 } }

        run_test! do |response|
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(JSON.parse(response.body)['error']).to eq('Produto não encontrado')
        end
      end

      response(422, 'Invalid quantity') do
        let!(:cart) { create(:cart, total_price: 0) }
        let!(:product) { create(:product, name: 'Invalid Quantity Product', price: 2.99) }
        before { post '/rack_session', params: { cart_id: cart.id } }
        let(:body) { { product_id: product.id, quantity: 0 } }

        run_test! do |response|
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(JSON.parse(response.body)['error']).to eq('Quantidade deve ser maior que zero')
        end
      end
    end
  end
end
