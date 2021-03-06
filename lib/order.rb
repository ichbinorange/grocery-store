require 'csv'
require_relative 'customer'

class Order
  attr_reader :id
  attr_accessor :products, :customer, :fulfillment_status

  def initialize(id, product, customer, fulfillment_status = :pending)
    @id = id
    @products = product
    @customer = customer

    raise ArgumentError.new("Invalid fulfillment status: #{ fulfillment_status }") unless [:pending, :paid, :processing, :shipped, :complete].include? (fulfillment_status)
    @fulfillment_status = fulfillment_status
  end

  def total
    return 0 if @products.count == 0
    sum = @products.values.reduce(:+) * 1.075
    return sum.round(2)
  end

  def add_product(name, price)
    raise ArgumentError.new("Invalid product: #{ name }") if @products.key? (name)
    @products[name] = price
    return @products
  end
  
  # Optional - remove_product
  def remove_product(rm_product)
    raise ArgumentError.new("Invalid product: #{ rm_product }") if !(@products.key? (rm_product))
    return @products.reject! { |name, price| name == rm_product } 
  end

  def self.all
    @order = CSV.read('data/orders.csv').map do |order| 
      product_hash = Hash.new
      order[1].split(";").each do |item|
        name, price = item.split(":")
        product_hash[name] = price.to_f
      end
      new(order[0].to_i, product_hash, Customer.find(order[2].to_i), order[3].to_sym)
    end
    return @order
  end

  def self.find(id)
    return all.find { |order| order.id == id }
  end
  
  # Optional - self.find_by_customer
  def self.find_by_customer(customer_id)
    return all.select { |order| order.customer == customer_id }
  end

end