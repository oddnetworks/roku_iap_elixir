defmodule RokuIAP do
  @moduledoc """
  Documentation for RokuIAP.
  """

  alias RokuIAP.Client

  @doc """
  Validates a subscription

  Args:
    * `api_key` - The Roku Developer API Key
    * `transaction_id` - The transaction ID to validate with Roku
  """
  @spec validate_transaction(String.t, String.t) :: HTTPoison.Response
  def validate_transaction(api_key, transaction_id) do
    Client.get("/validate-transaction/#{api_key}/#{transaction_id}")
  end

  @doc """
  Validates a refund

  Args:
    * `api_key` - The Roku Developer API Key
    * `refund_id` - The refund ID to validate with Roku
  """
  @spec validate_refund(String.t, String.t) :: HTTPoison.Response
  def validate_refund(api_key, refund_id) do
    Client.get("/validate-refund/#{api_key}/#{refund_id}")
  end

  @doc """
  Validates a refund

  Args:
    * `api_key` - The Roku Developer API Key
    * `refund_id` - The refund ID to validate with Roku
  """
  @spec cancel_subscription(String.t, String.t, String.t, DateTime.t) :: HTTPoison.Response
  def cancel_subscription(api_key, transaction_id, partner_reference_id, cancellation_date) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        cancellationDate: DateTime.to_iso8601(cancellation_date),
        partnerReferenceId: partner_reference_id
      }

    Client.post("/cancel-subscription", body, [{"content-type", "application/json"}])
  end

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `api_key` - The Roku Developer API Key
    * `transaction_id` - The transaction ID to update
    * `partner_reference_id`
    * `amount` - The amount to refund to the customer
    * `comment` - A comment note for the reason for the refund
  """
  @spec refund_subscription(String.t, String.t, String.t, integer, String.t) :: HTTPoison.Response
  def refund_subscription(api_key, transaction_id, partner_reference_id, amount, comment) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        amount: amount,
        partnerReferenceId: partner_reference_id,
        comments: comment
      }

    Client.post("/refund-subscription", body, [{"content-type", "application/json"}])
  end

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `api_key` - The Roku Developer API Key
    * `transaction_id` - The transaction ID to update
    * `new_billing_cycle_date` - The new date to set the billing cycle
  """
  @spec update_bill_cycle(String.t, String.t, DateTime.t) :: HTTPoison.Response
  def update_bill_cycle(api_key, transaction_id, new_bill_cycle_date) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        newBillCycleDate: DateTime.to_iso8601(new_bill_cycle_date)
      }

    Client.post("/update-bill-cycle", body, [{"content-type", "application/json"}])
  end

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `api_key` - The Roku Developer API Key
    * `channel_id` - The channel ID to issue a credit for
    * `partner_reference_id`
    * `product_id`
    * `roku_customer_id`
    * `amount` - The amount to refund to the customer
    * `comment` - A comment note for the reason for the credit
  """
  @spec issue_service_credit(String.t, String.t, String.t, String.t, String.t, integer, String.t) :: HTTPoison.Response
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

    Client.post("/issue-service-credit", body, [{"content-type", "application/json"}])
  end
end
