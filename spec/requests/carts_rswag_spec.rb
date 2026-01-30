# frozen_string_literal: true

require 'swagger_helper'
# frozen_string_literal: true

RSpec.describe 'Cart API', type: :request do
  path '/cart' do
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
          post '/cart/rack_session', params: { cart_id: cart.id }
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
        end
      end

      response(404, 'Cart not found') do
        run_test! do |response|
          expect(response).to have_http_status(404)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Carrinho não encontrado')
        end
      end
    end

    post('Create cart and add product') do
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

      response(201, 'Product added to cart') do
        let!(:cart) { create(:cart, total_price: 0) }
        let!(:product) { create(:product, name: 'Test Product', price: 1.99) }

        before do
          post '/cart/rack_session', params: { cart_id: cart.id }
        end

        let(:body) { { product_id: product.id, quantity: 2 } }

        run_test! do |response|
          expect(response).to have_http_status(201)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(JSON.parse(response.body)['id']).to be_a(Integer)
        end
      end

      response(404, 'Product not found') do
        let!(:cart) { create(:cart, total_price: 0) }
        before { post '/cart/rack_session', params: { cart_id: cart.id } }
        let(:body) { { product_id: 9999, quantity: 2 } }

        run_test! do |response|
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(JSON.parse(response.body)['error']).to eq('Produto não encontrado')
        end
      end

      response(422, 'Invalid quantity') do
        let!(:cart) { create(:cart, total_price: 0) }
        let!(:product) { create(:product, name: 'Invalid Quantity Product', price: 2.99) }
        before { post '/cart/rack_session', params: { cart_id: cart.id } }
        let(:body) { { product_id: product.id, quantity: 0 } }

        run_test! do |response|
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(JSON.parse(response.body)['error']).to eq('Quantidade deve ser maior que zero')
        end
      end
    end
  end

  path '/cart/add_item' do
    post('Update or add product in cart') do
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

      response(200, 'Product quantity updated or added in cart') do
        let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
        let!(:product2) { Product.create!(name: 'Produto Y', price: 9.9) }
        let!(:cart) { Cart.create!(total_price: 0) }

        before do
          cart.cart_items.create!(product: product1, quantity: 2, unit_price: 7.0)
          cart.cart_items.create!(product: product2, quantity: 1, unit_price: 9.9)
          post '/cart/rack_session', params: { cart_id: cart.id }
        end

        let(:body) { { product_id: product1.id, quantity: 5 } }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['products'].size).to eq(2)
          expect(json['products'][0]['id']).to eq(product1.id)
          expect(json['products'][0]['quantity']).to eq(7)
          expect(json['products'][1]['id']).to eq(product2.id)
          expect(json['products'][1]['quantity']).to eq(1)
        end
      end

      response(422, 'Invalid quantity') do
        let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
        let!(:cart) { Cart.create!(total_price: 0) }
        before { post '/cart/rack_session', params: { cart_id: cart.id } }
        let(:body) { { product_id: product1.id, quantity: 0 } }

        run_test! do |response|
          expect(response).to have_http_status(422)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Quantidade deve ser maior que zero')
        end
      end

      response(404, 'Cart not found') do
        let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
        let(:body) { { product_id: product1.id, quantity: 1 } }

        run_test! do |response|
          expect(response).to have_http_status(404)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Carrinho não encontrado')
        end
      end

      response(404, 'Product not found') do
        let!(:cart) { Cart.create!(total_price: 0) }
        before { post '/cart/rack_session', params: { cart_id: cart.id } }
        let(:body) { { product_id: 9999, quantity: 1 } }

        run_test! do |response|
          expect(response).to have_http_status(404)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Produto não encontrado')
        end
      end
    end
  end

  path '/cart/{product_id}' do
    delete('Remove product from cart') do
      tags 'Cart'
      produces 'application/json'
      description 'Removes a product from the cart by its ID. Returns the updated cart or an error.'

      parameter name: :product_id, in: :path, type: :integer, description: 'ID do produto a remover', required: true

      response(200, 'Product removed from cart') do
        schema type: :object,
               properties: {
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       quantity: { type: :integer },
                       unit_price: { type: :number },
                       total_price: { type: :number }
                     }
                   }
                 },
                 total_price: { type: :number }
               },
               required: %w[products total_price]

        let!(:cart) { Cart.create!(total_price: 0) }
        let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
        let!(:product2) { Product.create!(name: 'Produto Y', price: 9.9) }

        before do
          cart.cart_items.create!(product: product1, quantity: 2, unit_price: 7.0)
          cart.cart_items.create!(product: product2, quantity: 1, unit_price: 9.9)
          post '/cart/rack_session', params: { cart_id: cart.id }
        end

        let(:product_id) { product1.id }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['products'].size).to eq(1)
          expect(json['products'][0]['id']).to eq(product2.id)
          expect(json['total_price']).to eq(9.9)
        end
      end

      response(404, 'Product not found') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error']

        let!(:cart) { Cart.create!(total_price: 0) }
        let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
        before { post '/cart/rack_session', params: { cart_id: cart.id } }
        let(:product_id) { 9999 }

        run_test! do |response|
          expect(response).to have_http_status(404)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Produto não encontrado')
        end
      end

      response(404, 'Cart not found') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: ['error']

        let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
        let(:product_id) { product1.id }

        run_test! do |response|
          expect(response).to have_http_status(404)
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Carrinho não encontrado')
        end
      end

      response(200, 'Cart empty after removal') do
        schema type: :object,
               properties: {
                 products: { type: :array, items: { type: :object } },
                 total_price: { type: :number }
               },
               required: %w[products total_price]

        let!(:cart) { Cart.create!(total_price: 0) }
        let!(:product1) { Product.create!(name: 'Produto X', price: 7.0) }
        before do
          cart.cart_items.create!(product: product1, quantity: 2, unit_price: 7.0)
          post '/cart/rack_session', params: { cart_id: cart.id }
        end
        let(:product_id) { product1.id }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['products']).to eq([])
          expect(json['total_price']).to eq(0.0)
        end
      end
    end
  end
end
