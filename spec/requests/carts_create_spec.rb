# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /cart', type: :request do
  let!(:product) { Product.create!(name: 'Produto X', price: 7.0) }

  it 'removes the cart when the add item service fails' do
    service = instance_double(Carts::AddItemService)
    allow(Carts::AddItemService).to receive(:new).and_return(service)
    allow(service).to receive(:call).and_raise(ActiveRecord::RecordInvalid.new(Cart.new))

    expect do
      post '/cart', params: { product_id: product.id, quantity: 1 }
    end.not_to change(Cart, :count)

    expect(response).to have_http_status(422)
  end
end
