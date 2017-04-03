defmodule RokuIAPTest do
  use ExUnit.Case, async: true
  
  import :meck
  alias RokuIAP

  setup do
    new :hackney
    on_exit fn -> unload() end
    :ok
  end

  test "validate_transaction/2" do
    {:ok, date, _} = DateTime.from_iso8601("2012-07-22T14:59:50Z")

    transaction = %RokuIAP.Transaction{
      transaction_id: "t_1",
      purchase_date: date,
      channel_name: "123Video",
      product_name: "123Video Monthly Subscription",
      product_id: "NETMONTH",
      amount: 9.99,
      currency: :USD,
      quantity: 1,
      roku_customer_id: "abcdefghijklmnop",
      expiration_date: date,
      original_purchase_date: date
    }

    response = %{
      "transactionId" => "t_1",
      "purchaseDate" => "2012-07-22T14:59:50Z",
      "channelName" => "123Video",
      "productName" => "123Video Monthly Subscription",
      "productId" => "NETMONTH",
      "amount" => 9.99,
      "currency" => "USD",
      "quantity" => 1,
      "rokuCustomerId" => "abcdefghijklmnop",
      "expirationDate" => "2012-07-22T14:59:50Z",
      "originalPurchaseDate" => "2012-07-22T14:59:50Z",
      "status" => "Success",
      "errorMessage" => "error_message"
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:get, "https://apipub.roku.com/listen/transaction-service.svc/validate-transaction/k_1/t_1", [{"accept", "application/json"}], "", []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:ok, transaction} == RokuIAP.validate_transaction("k_1", "t_1")

    assert validate :hackney
  end

  test "validate_refund/2" do
    {:ok, date, _} = DateTime.from_iso8601("2012-07-22T14:59:50Z")

    transaction = %RokuIAP.Transaction{
      transaction_id: "t_1",
      purchase_date: date,
      channel_name: "123Video",
      product_name: "123Video Monthly Subscription",
      product_id: "NETMONTH",
      amount: 9.99,
      currency: :USD,
      quantity: 1,
      roku_customer_id: "abcdefghijklmnop",
      expiration_date: date,
      original_purchase_date: date
    }

    response = %{
      "transactionId" => "t_1",
      "purchaseDate" => "2012-07-22T14:59:50Z",
      "channelName" => "123Video",
      "productName" => "123Video Monthly Subscription",
      "productId" => "NETMONTH",
      "amount" => 9.99,
      "currency" => "USD",
      "quantity" => 1,
      "rokuCustomerId" => "abcdefghijklmnop",
      "expirationDate" => "2012-07-22T14:59:50Z",
      "originalPurchaseDate" => "2012-07-22T14:59:50Z",
      "status" => "Success",
      "errorMessage" => "error_message"
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:get, "https://apipub.roku.com/listen/transaction-service.svc/validate-refund/k_1/t_1", [{"accept", "application/json"}], "", []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:ok, transaction} == RokuIAP.validate_refund("k_1", "t_1")

    assert validate :hackney
  end

  test "cancel_subscription/4" do
    cancellation_date = %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "UTC",
                                  hour: 23, minute: 0, second: 7, microsecond: {0, 0},
                                  utc_offset: 0, std_offset: 0, time_zone: "Etc/UTC"}
    request = %{
      "transactionId" => "t_3",
      "partnerReferenceId" => "p_1",
      "partnerAPIKey" => "k_1",
      "cancellationDate" => cancellation_date
    }

    response = %{
      "status" => "Success"
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://apipub.roku.com/listen/transaction-service.svc/cancel-subscription", [{"accept", "application/json"}, {"content-type", "application/json"}], Poison.encode!(request), []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert :ok == RokuIAP.cancel_subscription("k_1", "t_3", "p_1", cancellation_date)

    assert validate :hackney
  end

  test "refund_subscription/4" do
    request = %{
      "transactionId" => "t_3",
      "partnerReferenceId" => "p_1",
      "partnerAPIKey" => "k_1",
      "amount" => 6.66,
      "comments" => "cuz roku"
    }

    response = %{
      "status" => "Success",
      "refundId" => "r_3"
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://apipub.roku.com/listen/transaction-service.svc/refund-subscription", [{"accept", "application/json"}, {"content-type", "application/json"}], Poison.encode!(request), []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:ok, "r_3"} == RokuIAP.refund_subscription("k_1", "t_3", "p_1", 6.66, "cuz roku")

    assert validate :hackney
  end

  test "update_billing_cycle/4" do
    billing_cycle_date = %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "UTC",
                                   hour: 23, minute: 0, second: 7, microsecond: {0, 0},
                                   utc_offset: 0, std_offset: 0, time_zone: "Etc/UTC"}
    request = %{
      "transactionId" => "t_3",
      "partnerAPIKey" => "k_1",
      "newBillCycleDate" => billing_cycle_date
    }

    response = %{
      "status" => "Success"
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://apipub.roku.com/listen/transaction-service.svc/update-bill-cycle", [{"accept", "application/json"}, {"content-type", "application/json"}], Poison.encode!(request), []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert :ok == RokuIAP.update_bill_cycle("k_1", "t_3", billing_cycle_date)

    assert validate :hackney
  end

  test "issue_service_credit/4" do
    request = %{
      "partnerAPIKey": "k_1",
      "channelId": "c_1",
      "amount": 6.66,
      "partnerReferenceId": "p_r_1",
      "productId": "p_1",
      "rokuCustomerId": "r_c_1",
      "comments": "cuz roku"
    }

    response = %{
      "status" => "Success",
      "referenceId" => "r_1"
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://apipub.roku.com/listen/transaction-service.svc/issue-service-credit", [{"accept", "application/json"}, {"content-type", "application/json"}], Poison.encode!(request), []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:ok, "r_1"} == RokuIAP.issue_service_credit("k_1", "c_1", "p_r_1", "p_1", "r_c_1", 6.66, "cuz roku")

    assert validate :hackney
  end
end
