defmodule RokuIAP do
  @moduledoc """
  Documentation for RokuIAP.
  """

  alias RokuIAP.Client

  defmodule Transaction do
    defstruct(transaction_id: nil,
              purchase_date: nil,
              channel_name: nil,
              product_name: nil,
              product_id: nil,
              amount: nil,
              currency: nil,
              quantity: nil,
              roku_customer_id: nil,
              expiration_date: nil,
              original_purchase_date: nil)
  end

  @doc """
  Validates a subscription

  Args:
    * `api_key` - The Roku Developer API Key
    * `transaction_id` - The transaction ID to validate with Roku
  """
  @spec validate_transaction(String.t, String.t) :: {:ok, Transaction.t | :error, String.t}
  def validate_transaction(api_key, transaction_id) do
    case Client.get("/validate-transaction/#{api_key}/#{transaction_id}") do
      {:ok, response} -> to_transaction(response.body)
      {:error, error} -> {:error, error.reason}
    end
  end

  @doc """
  Validates a refund

  Args:
    * `api_key` - The Roku Developer API Key
    * `refund_id` - The refund ID to validate with Roku
  """
  @spec validate_refund(String.t, String.t) :: {:ok, Transaction.t | :error, String.t}
  def validate_refund(api_key, refund_id) do
    case Client.get("/validate-refund/#{api_key}/#{refund_id}") do
      {:ok, response} -> to_transaction(response.body)
      {:error, error} -> {:error, error.reason}
    end
  end

  @doc """
  Validates a refund

  Args:
    * `api_key` - The Roku Developer API Key
    * `refund_id` - The refund ID to validate with Roku
  """
  @spec cancel_subscription(String.t, String.t, String.t, DateTime.t) :: {:ok | :error, String.t}
  def cancel_subscription(api_key, transaction_id, partner_reference_id, cancellation_date) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        cancellationDate: DateTime.to_iso8601(cancellation_date),
        partnerReferenceId: partner_reference_id
      }

    case Client.post("/cancel-subscription", body, [{"content-type", "application/json"}]) do
      {:ok, response} -> parse_body(response.body)
      {:error, error} -> {:error, error.reason}
    end
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
  @spec refund_subscription(String.t, String.t, String.t, integer, String.t) :: {:ok, String.t | :error, String.t}
  def refund_subscription(api_key, transaction_id, partner_reference_id, amount, comment) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        amount: amount,
        partnerReferenceId: partner_reference_id,
        comments: comment
      }

    case Client.post("/refund-subscription", body, [{"content-type", "application/json"}]) do
      {:ok, response} -> 
        case parse_body(response.body) do
          :ok -> {:ok, response.body["refundId"]}
          {:error, reason} -> {:error, reason}
        end
      {:error, error} -> {:error, error.reason}
    end
  end

  @doc """
  Updates a previous transaction with a new billing cycle date

  Args:
    * `api_key` - The Roku Developer API Key
    * `transaction_id` - The transaction ID to update
    * `new_billing_cycle_date` - The new date to set the billing cycle
  """
  @spec update_bill_cycle(String.t, String.t, DateTime.t) :: {:ok | :error, String.t}
  def update_bill_cycle(api_key, transaction_id, new_bill_cycle_date) do
    body = %{
        partnerAPIKey: api_key,
        transactionId: transaction_id,
        newBillCycleDate: DateTime.to_iso8601(new_bill_cycle_date)
      }

    case Client.post("/update-bill-cycle", body, [{"content-type", "application/json"}]) do
      {:ok, response} -> parse_body(response.body)
      {:error, error} -> {:error, error.reason}
    end
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
  @spec issue_service_credit(String.t, String.t, String.t, String.t, String.t, integer, String.t) :: {:ok, String.t | :error, String.t}
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

    case Client.post("/issue-service-credit", body, [{"content-type", "application/json"}]) do
      {:ok, response} -> 
        case parse_body(response.body) do
          :ok -> {:ok, response.body["referenceId"]}
          {:error, reason} -> {:error, reason}
        end
      {:error, error} -> {:error, error.reason}
    end
  end

  defp to_transaction(body) do
    case parse_body(body) do
      :ok -> 
        {:ok, purchase_date, _} = DateTime.from_iso8601(body["purchaseDate"])
        {:ok, expiration_date, _} = DateTime.from_iso8601(body["expirationDate"])
        {:ok, original_purchase_date, _} = DateTime.from_iso8601(body["originalPurchaseDate"])

        {:ok, %Transaction{
          transaction_id: body["transactionId"],
          purchase_date: purchase_date,
          channel_name: body["channelName"],
          product_name: body["productName"],
          product_id: body["productId"],
          amount: body["amount"],
          currency: String.to_atom(body["currency"]),
          quantity: body["quantity"],
          roku_customer_id: body["rokuCustomerId"],
          expiration_date: expiration_date,
          original_purchase_date: original_purchase_date
        }}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_body(body) do
    case body["status"] do
      "Success" -> :ok
      _default -> {:error, body["errorMessage"]}
    end
  end
end
