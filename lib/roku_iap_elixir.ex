defmodule RokuIapElixir do
  use HTTPoison.Base
  
  @moduledoc """
  Documentation for RokuIapElixir.
  """

  def process_url(url) do
    "https://apipub.roku.com/listen/transaction-service.svc" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end

  def validate_transaction(web_api_key, transaction_id) do
    process_url("/validate-transaction/#{web_api_key}/#{transaction_id}")
    |> get
    |> process_response_body
  end

  def validate_refund(web_api_key, refund_id) do
    process_url("/validate-refund/#{web_api_key}/#{refund_id}")
    |> get
    |> process_response_body
  end

  def cancel_subscription(web_api_key, transaction_id, partner_reference_id, cancellation_date) do
    body = Poison.encode!(%{
        partnerAPIKey: web_api_key,
        transactionId: transaction_id,
        cancellationDate: cancellation_date,
        partnerReferenceId: partner_reference_id
      })

    process_url("/cancel-subscription")
    |> post(body, [{"Content-Type", "application/json"}])
    |> process_response_body
  end

  def refund_subscription(web_api_key, transaction_id, partner_reference_id, amount, refund_comment) do
    body = Poison.encode!(%{
        partnerAPIKey: web_api_key,
        transactionId: transaction_id,
        amount: amount,
        partnerReferenceId: partner_reference_id,
        comments: refund_comment
      })

    process_url("/refund-subscription")
    |> post(body, [{"Content-Type", "application/json"}])
    |> process_response_body
  end
end
