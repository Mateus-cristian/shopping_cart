# frozen_string_literal: true

module Carts
  class UpdateItemService
    def initialize(cart:, product:, quantity:)
      raise ArgumentError, 'Cart é obrigatório' unless cart
      raise ActiveRecord::RecordNotFound, 'Produto não encontrado' unless product

      @cart = cart
      @product = product
      @quantity = quantity.to_i
    end

    def call
      validate!
      @cart.transaction do
        add_or_update_item
        update_cart_total
        touch_last_interaction
      end
      @cart
    end

    private

    def add_or_update_item
      item = find_cart_item
      if item
        item.update!(quantity: item.quantity + @quantity)
      else
        @cart.cart_items.create!(product: @product, quantity: @quantity, unit_price: @product.price)
      end
    end

    def find_cart_item
      @cart.cart_items.find_by(product_id: @product.id)
    end

    def update_cart_total
      @cart.update!(total_price: calculate_total)
    end

    def calculate_total
      @cart.cart_items.sum('quantity * unit_price')
    end

    def validate!
      raise ArgumentError, 'Quantidade deve ser maior que zero' if @quantity <= 0
    end

    def touch_last_interaction
      @cart.update!(last_interaction_at: Time.current)
    end
  end
end
