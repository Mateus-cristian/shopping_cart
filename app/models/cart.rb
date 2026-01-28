# frozen_string_literal: true

class Cart < ApplicationRecord
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
