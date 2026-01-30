# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def as_json(_options = {})
    {
      id:,
      products: products_json,
      total_price: total_price.to_f
    }
  end

  private

  def products_json
    cart_items.includes(:product).map do |item|
      {
        id: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unit_price: item.unit_price.to_f,
        total_price: (item.quantity * item.unit_price).to_f
      }
    end
  end
end
