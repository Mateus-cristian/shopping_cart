# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Carts::RemoveItemService, type: :service do
  let(:cart) { Cart.create!(total_price: 0) }
  let(:product) { Product.create!(name: 'Produto X', price: 10.0) }

  context 'when the product is in the cart' do
    before do
      cart.cart_items.create!(product:, quantity: 2, unit_price: 10.0)
    end
    it 'removes the item from the cart and updates the total' do
      service = described_class.new(cart:, product_id: product.id)
      service.call
      expect(cart.cart_items.find_by(product_id: product.id)).to be_nil
      expect(cart.reload.total_price).to eq(0.0)
    end
  end

  context 'when the product is not in the cart' do
    it 'raises ActiveRecord::RecordNotFound error' do
      expect do
        described_class.new(cart:, product_id: 9999).call
      end.to raise_error(ActiveRecord::RecordNotFound, 'Produto não encontrado')
    end
  end
end
