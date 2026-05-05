

module Orders
  class DeductStock
    Result = Struct.new(:success?, :error, keyword_init: true)

    def initialize(order:)
      @order = order
    end

    def call
      ActiveRecord::Base.transaction do
        @order.order_items.includes(:product).find_each do |item|
          next if item.quantity.to_i <= 0

          product = Product.lock.find(item.product_id) # FOR UPDATE
          if item.quantity.to_i > product.stock_quantity.to_i
            return Result.new(success?: false,
                              error: "Nema dovoljno zalihe za '#{product.name}'. Na zalihi: #{product.stock_quantity}. Traženo: #{item.quantity}.")
          end

          product.update!(stock_quantity: product.stock_quantity - item.quantity.to_i)
        end
      end

      Result.new(success?: true, error: nil)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, error: e.record.errors.full_messages.to_sentence)
    end
  end
end
