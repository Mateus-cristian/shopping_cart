# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items
  validates :name, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def as_json(options = {})
    super(options).merge('price' => price.to_f)
  end
end
