defmodule RokuIapElixir do
  @moduledoc """
  Documentation for RokuIapElixir.
  """

  alias RokuIapElixir.Client

  def validate_transaction(api_key, transaction_id) do
    Client.get("/validate-transaction/#{api_key}/#{transaction_id}")
  end

  def validate_refund(api_key, refund_id) do
    Client.get("/validate-refund/#{api_key}/#{refund_id}")
  end

  def cancel_subscription(api_key, transaction_id, partner_reference_id, cancellation_date) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        cancellationDate: DateTime.to_iso8601(cancellation_date),
        partnerReferenceId: partner_reference_id
      }

    Client.post("/cancel-subscription", body, [{"Content-Type", "application/json"}])
  end

  def refund_subscription(api_key, transaction_id, partner_reference_id, amount, comment) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        amount: amount,
        partnerReferenceId: partner_reference_id,
        comments: comment
      }

    Client.post("/refund-subscription", body, [{"Content-Type", "application/json"}])
  end

  def update_bill_cycle(api_key, transaction_id, new_bill_cycle_date) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        newBillCycleDate: DateTime.to_iso8601(new_bill_cycle_date)
      }

    Client.post("/update-bill-cycle", body, [{"Content-Type", "application/json"}])
  end

  def issue_service_credit(api_key, channel_id, partner_reference_id, product_id, roku_customer_id, amount, comment) do
    body = %{
        partnerAPIKey: api_key,
        channelId: channel_id,
        amount: amount,
        partnerReferenceId: partner_reference_id,
        productId: product_id,
        rokuCustomerId: roku_customer_id,
        comments: comment
      }

    Client.post("/issue-service-credit", body, [{"Content-Type", "application/json"}])
  end
end
