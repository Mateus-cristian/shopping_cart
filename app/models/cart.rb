# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def as_json(_options = {})
    {
      id:,
      items: items_json,
      total_price:
    }
  end

  private

  def items_json
    cart_items.map do |item|
      {
        product_id: item.product_id,
        quantity: item.quantity,
        unit_price: item.unit_price,
        total_price: item.quantity * item.unit_price
      }
    end
  end
end
