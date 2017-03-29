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
    case body do
      "" -> body
      _ -> body |> Poison.encode!
    end
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
    body = %{
        partnerAPIKey: web_api_key,
        transactionId: transaction_id,
        cancellationDate: cancellation_date,
        partnerReferenceId: partner_reference_id
      }

    post("/cancel-subscription", body, [{"Content-Type", "application/json"}])
  end

  def refund_subscription(web_api_key, transaction_id, partner_reference_id, amount, comment) do
    body = %{
        partnerAPIKey: web_api_key,
        transactionId: transaction_id,
        amount: amount,
        partnerReferenceId: partner_reference_id,
        comments: comment
      }

    post("/refund-subscription", body, [{"Content-Type", "application/json"}])
  end

  def update_bill_cycle(web_api_key, transaction_id, new_bill_cycle_date) do
    body = %{
        partnerAPIKey: web_api_key,
        transactionId: transaction_id,
        newBillCycleDate: new_bill_cycle_date
      }

    post("/update-bill-cycle", body, [{"Content-Type", "application/json"}])
  end

  def issue_service_credit(web_api_key, channel_id, partner_reference_id, product_id, roku_customer_id, amount, comment) do
    body = %{
        partnerAPIKey: web_api_key,
        channelId: channel_id,
        amount: amount,
        partnerReferenceId: partner_reference_id,
        productId: product_id,
        rokuCustomerId: roku_customer_id,
        comments: comment
      }

    post("/issue-service-credit", body, [{"Content-Type", "application/json"}])
  end
end
