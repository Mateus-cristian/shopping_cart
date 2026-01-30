# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :set_cart, only: %i[show destroy]

  def show
    raise ActiveRecord::RecordNotFound, 'Carrinho não encontrado' unless @cart

    render json: @cart, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def create
    cart = add_item_to_new_cart
    render json: cart, status: :created
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def add_item
    product  = find_product!
    quantity = validate_quantity!
    cart     = current_cart
    raise ActiveRecord::RecordNotFound, 'Carrinho não encontrado' unless cart

    Carts::UpdateItemService.new(cart:, product:, quantity:).call
    render json: cart, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    cart = current_cart
    raise ActiveRecord::RecordNotFound, 'Carrinho não encontrado' unless cart

    payload = Carts::RemoveItemService.new(cart:, product_id: params[:product_id]).payload
    render json: payload, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  private

  def current_cart
    @current_cart ||= Cart.find_by(id: session[:cart_id])
  end

  def create_cart
    cart = Cart.create!(total_price: 0, last_interaction_at: Time.current)
    session[:cart_id] = cart.id
    @current_cart = cart
  end

  def set_cart
    @cart = current_cart
  end

  def validate_quantity!
    quantity = params[:quantity].to_i
    raise ArgumentError, 'Quantidade deve ser maior que zero' if quantity <= 0

    quantity
  end

  def find_product!
    Product.find_by(id: params[:product_id]) || raise(ActiveRecord::RecordNotFound, 'Produto não encontrado')
  end

  def add_item_to_new_cart
    product  = find_product!
    quantity = validate_quantity!
    cart     = create_cart
    Carts::AddItemService.new(cart:, product:, quantity:).call
    cart
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    cleanup_cart(cart)
    raise e
  end

  def cleanup_cart(cart)
    cart.destroy if cart&.persisted?
    session.delete(:cart_id)
    @current_cart = nil
  end
end
