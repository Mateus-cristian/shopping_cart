# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Carts::UpdateItemService, type: :service do
  let(:cart) { Cart.create!(total_price: 0) }
  let(:product) { Product.create!(name: 'Produto X', price: 10.0) }

  context 'when the product is already in the cart' do
    before do
      cart.cart_items.create!(product:, quantity: 2, unit_price: 10.0)
    end

    it 'increments the item quantity' do
      service = described_class.new(cart:, product:, quantity: 3)
      service.call
      item = cart.cart_items.find_by(product_id: product.id)
      expect(item.quantity).to eq(5)
      expect(cart.reload.total_price).to eq(50.0)
    end
  end

  context 'when the product is not in the cart' do
    it 'adds the product to the cart' do
      service = described_class.new(cart:, product:, quantity: 2)
      service.call
      item = cart.cart_items.find_by(product_id: product.id)
      expect(item).not_to be_nil
      expect(item.quantity).to eq(2)
      expect(item.unit_price).to eq(10.0)
      expect(cart.reload.total_price).to eq(20.0)
    end
  end

  context 'when the quantity is invalid' do
    it 'raises an error for zero quantity' do
      expect do
        described_class.new(cart:, product:, quantity: 0).call
      end.to raise_error(ArgumentError, 'Quantidade deve ser maior que zero')
    end
    it 'raises an error for negative quantity' do
      expect do
        described_class.new(cart:, product:, quantity: -1).call
      end.to raise_error(ArgumentError, 'Quantidade deve ser maior que zero')
    end
  end

  context 'when the product does not exist' do
    it 'raises ActiveRecord::RecordNotFound' do
      expect do
        described_class.new(cart:, product: nil, quantity: 1).call
      end.to raise_error(ActiveRecord::RecordNotFound, 'Produto não encontrado')
    end
  end
end
