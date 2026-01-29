# frozen_string_literal: true

PRODUCT_SCHEMA = {
  type: :object,
  required: %w[id name price],
  properties: {
    id: { type: :integer },
    name: { type: :string },
    price: { type: :number }
  }
}.freeze
