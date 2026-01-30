# frozen_string_literal: true

module Carts
  class AddItemService
    def initialize(cart:, product:, quantity:)
      @cart = cart
      @product = product
      @quantity = quantity
    end

    def call
      validate!
      @cart.transaction do
        add_or_update_item
        update_cart_total
      end
      @cart
    end

    def self.add_item(cart:, product_id:, quantity:)
      product = Product.find_by(id: product_id)
      new(cart:, product:, quantity:).call
    end

    private

    def add_or_update_item
      cart_item = find_cart_item
      if cart_item
        cart_item.quantity += @quantity
        cart_item.save!
      else
        @cart.cart_items.create!(product: @product, quantity: @quantity, unit_price: @product.price)
      end
    end

    def find_cart_item
      @cart.cart_items.find_by(product_id: @product.id)
    end

    def validate!
      raise ArgumentError, 'Quantidade deve ser maior que zero' if @quantity.to_i <= 0
      raise ActiveRecord::RecordNotFound, 'Produto não encontrado' unless @product
    end

    def update_cart_total
      @cart.update!(total_price: @cart.cart_items.sum('quantity * unit_price'))
    end
  end
end
