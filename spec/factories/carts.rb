# frozen_string_literal: true

FactoryBot.define do
  factory :cart do
    total_price { 0 }
    status { :active }
    last_interaction_at { Time.current }
  end
end
