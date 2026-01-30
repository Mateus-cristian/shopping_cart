# frozen_string_literal: true

module Carts
  class AddItemService
    def initialize(cart:, product:, quantity:)
      @cart = cart
      @product = product
      @quantity = quantity
    end

    def call
      validate_inputs
      @cart.transaction do
        add_or_update_item
        update_cart_total
      end
      @cart
    end

    private

    def validate_inputs
      raise ArgumentError, 'Quantidade deve ser maior que zero' if @quantity <= 0
      raise ActiveRecord::RecordNotFound, 'Produto não encontrado' unless @product
    end

    def add_or_update_item
      cart_item = @cart.cart_items.find_by(product_id: @product.id)
      if cart_item
        cart_item.quantity += @quantity
        cart_item.save!
      else
        @cart.cart_items.create!(product: @product, quantity: @quantity, unit_price: @product.price)
      end
    end

    def update_cart_total
      @cart.update!(total_price: @cart.cart_items.sum('quantity * unit_price'))
    end
  end
end
