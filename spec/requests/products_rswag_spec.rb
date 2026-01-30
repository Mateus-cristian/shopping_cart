# frozen_string_literal: true

require 'swagger_helper'
require 'support/schemas/product_schema'

RSpec.describe 'Products API', type: :request do
  path '/products' do
    get('list products') do
      tags 'Products'
      produces 'application/json'
      response(200, 'successful') do
        schema type: :array, items: PRODUCT_SCHEMA
        run_test!
      end
    end
    post('create product') do
      tags 'Products'
      consumes 'application/json'
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          price: { type: :number }
        },
        required: %w[name price]
      }
      response(201, 'created') do
        let(:product) { { name: 'Produto', price: 10 } }
        run_test!
      end
    end
  end
  path '/products/{id}' do
    parameter name: :id, in: :path, type: :string
    get('show product') do
      tags 'Products'
      produces 'application/json'
      response(200, 'successful') do
        let!(:product) { create(:product, name: 'Show Product', price: 9.99) }
        let(:id) { product.id }
        schema PRODUCT_SCHEMA
        run_test!
      end
    end
    delete('delete product') do
      tags 'Products'
      response(204, 'no content') do
        let!(:product) { create(:product, name: 'Delete Product', price: 5.99) }
        let(:id) { product.id }
        run_test!
      end
    end
  end
end
