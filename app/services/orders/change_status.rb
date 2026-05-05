

module Orders
  class ChangeStatus
    Result = Struct.new(:success?, :error, keyword_init: true)

    TRANSITIONS = {
      'draft' => %w[submitted cancelled],
      'submitted' => %w[approved rejected cancelled],
      'approved' => %w[preparing],
      'preparing' => %w[shipped],
      'shipped' => %w[delivered],
      'rejected' => [],
      'delivered' => [],
      'cancelled' => []
    }.freeze

    def initialize(order:, user:, to_status:, note: nil)
      @order = order
      @user = user
      @to_status = to_status.to_s
      @note = note
    end

    def call
      return Result.new(success?: false, error: 'Invalid status') unless Order.statuses.key?(@to_status)
      return Result.new(success?: false, error: 'Transition not allowed') unless allowed_transition?
      return Result.new(success?: false, error: 'Not authorized') unless authorized_actor?

      from = @order.status

      Order.transaction do
        @order.update!(status: @to_status)

        # 👇 SIDE EFFECTS PO STATUSIMA
        if @to_status == 'approved'
          if from == 'submitted'
            stock_result = Orders::DeductStock.new(order: @order).call
            raise stock_result.error unless stock_result.success?
          end

          @order.update!(
            approved_at: Time.zone.now,
            due_date: Time.zone.today + @order.company.payment_terms_days.to_i.days
          )
        elsif @to_status == 'delivered'
          @order.update!(delivered_at: Time.zone.now)
        end

        @order.order_status_histories.create!(
          changed_by: @user,
          from_status: Order.statuses[from],
          to_status: Order.statuses[@to_status],
          note: @note
        )
      end

      Result.new(success?: true, error: nil)
    rescue StandardError => e
      Result.new(success?: false, error: e.message)
    end

    private

    def allowed_transition?
      TRANSITIONS.fetch(@order.status, []).include?(@to_status)
    end

    def authorized_actor?
      if @user.partner_user?
        return %w[submitted cancelled].include?(@to_status) && %w[draft submitted].include?(@order.status)
      end

      @user.admin?
    end
  end
end
