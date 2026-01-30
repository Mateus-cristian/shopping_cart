# frozen_string_literal: true

module Carts
  class RemoveItemService
    def initialize(cart:, product_id:)
      @cart = cart
      @product_id = product_id
    end

    def call
      cart_item = @cart.cart_items.find_by(product_id: @product_id)
      raise ActiveRecord::RecordNotFound, 'Produto não encontrado' unless cart_item

      cart_item.destroy!
      update_cart_total
      touch_last_interaction
      @cart
    end

    def payload
      call
      @cart.as_json
    end

    private

    def update_cart_total
      @cart.update!(total_price: @cart.cart_items.sum('quantity * unit_price'))
    end

    def touch_last_interaction
      @cart.update!(last_interaction_at: Time.current)
    end
  end
end
