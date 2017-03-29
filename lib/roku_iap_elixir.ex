defmodule RokuIapElixir do
  use HTTPoison.Base
  
  @moduledoc """
  Documentation for RokuIapElixir.
  """

  def process_url(url) do
    "https://apipub.roku.com/listen/transaction-service.svc" <> url
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
  end

  defp process_request_body(body) do
    IO.inspect body
    body
  end

  defp process_request_headers(headers) do
    [{"Accept", "application/json"} | headers]
  end

  defp process_request_options(options) do
    [[ ssl: [{:versions, [:'tlsv1.2']}] ] | options]
  end

  def validate_transaction(web_api_key, transaction_id) do
    get("/validate-transaction/#{web_api_key}/#{transaction_id}")
  end

  def validate_refund(web_api_key, refund_id) do
    get("/validate-refund/#{web_api_key}/#{refund_id}")
  end

  def cancel_subscription(web_api_key, transaction_id, partner_reference_id, cancellation_date) do
    body = Poison.encode!(%{
        partnerAPIKey: web_api_key,
        transactionId: transaction_id,
        cancellationDate: cancellation_date,
        partnerReferenceId: partner_reference_id
      })

    post("/cancel-subscription", body, [{"Content-Type", "application/json"}])
  end

  def refund_subscription(web_api_key, transaction_id, partner_reference_id, amount, refund_comment) do
    body = Poison.encode!(%{
        partnerAPIKey: web_api_key,
        transactionId: transaction_id,
        amount: amount,
        partnerReferenceId: partner_reference_id,
        comments: refund_comment
      })

    post("/refund-subscription", body, [{"Content-Type", "application/json"}])
  end
end
