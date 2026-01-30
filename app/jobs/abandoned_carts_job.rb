# frozen_string_literal: true

class AbandonedCartsJob < ApplicationJob
  queue_as :default

  def perform
    mark_inactive_carts
    remove_old_abandoned_carts
  end

  private

  def mark_inactive_carts
    Cart.active.where('last_interaction_at <= ?', 3.hours.ago).find_each(&:mark_as_abandoned)
  end

  def remove_old_abandoned_carts
    Cart.abandoned.where('last_interaction_at <= ?', 7.days.ago).find_each(&:remove_if_abandoned)
  end
end
