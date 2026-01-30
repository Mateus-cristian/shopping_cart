# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :current_cart, only: %i[show add_item]

  def show
    render json: current_cart
  end

  def create
    product_id = params[:product_id]
    quantity = params[:quantity].to_i
    if quantity <= 0
      return render json: { error: 'Quantidade deve ser maior que zero' },
                    status: :unprocessable_entity
    end

    product = Product.find_by(id: product_id)
    return render json: { error: 'Produto não encontrado' }, status: :not_found unless product

    begin
      cart = build_cart_with_product(product, quantity)
      session[:cart_id] = cart.id
      render json: cart, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def add_item
    product_id = params[:product_id]
    quantity = params[:quantity].to_i
    product = Product.find_by(id: product_id)

    begin
      cart = Carts::AddItemService.new(cart: current_cart, product:, quantity:).call
      render json: cart, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def add_product_to_cart
    product = Product.find(params[:product_id])
    @cart.add_item(product, params[:quantity].to_i)
  end

  def current_cart
    @current_cart ||= Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create!(total_price: 0)
    session[:cart_id] = cart.id
    @current_cart = cart
  end

  def build_cart_with_product(product, quantity)
    cart = Cart.create!(total_price: 0)
    cart.cart_items.create!(product:, quantity:, unit_price: product.price)
    cart
  end
end
