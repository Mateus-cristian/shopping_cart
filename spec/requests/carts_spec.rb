# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/carts' do
  describe 'POST /add_items' do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: 'Test Product', price: 10.0) }
    let!(:cart_item) { CartItem.create(cart:, product:, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
