# frozen_string_literal: true

class AddLastInteractionAndStatusToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :last_interaction_at, :datetime, default: -> { 'CURRENT_TIMESTAMP' }, null: false
    add_index :carts, :last_interaction_at

    add_column :carts, :status, :integer, default: 0, null: false
    add_index :carts, :status
  end
end
