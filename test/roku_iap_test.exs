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
    response = %{
      "transactionId" => "t_1",
      "purchaseDate" => "2012-07-22T14:59:50",
      "channelName" => "123Video",
      "productName" => "123Video Monthly Subscription",
      "productId" => "NETMONTH",
      "amount" => 9.99,
      "currency" => "USD",
      "quantity" => 1,
      "rokuCustomerId" => "abcdefghijklmnop",
      "expirationDate" => "2012-08-22T14:59:50",
      "originalPurchaseDate" => "2010-08-22T14:59:50",
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

    assert RokuIAP.validate_transaction("k_1", "t_1") ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: response
        }
      }

    assert validate :hackney
  end

  test "validate_refund/2" do
    response = %{
      "transactionId" => "t_2",
      "purchaseDate" => "2012-07-22T14:59:50",
      "channelName" => "123Video",
      "productName" => "123Video Monthly Subscription",
      "productId" => "NETMONTH",
      "amount" => 9.99,
      "currency" => "USD",
      "quantity" => 1,
      "rokuCustomerId" => "abcdefghijklmnop",
      "expirationDate" => "2012-08-22T14:59:50",
      "originalPurchaseDate" => "2010-08-22T14:59:50",
      "status" => "Success",
      "errorMessage" => "error_message"
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:get, "https://apipub.roku.com/listen/transaction-service.svc/validate-refund/k_1/t_2", [{"accept", "application/json"}], "", []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert RokuIAP.validate_refund("k_1", "t_2") ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: response
        }
      }

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
      "transactionId" => "t_2",
      "purchaseDate" => "2012-07-22T14:59:50",
      "channelName" => "123Video",
      "productName" => "123Video Monthly Subscription",
      "productId" => "NETMONTH",
      "amount" => 9.99,
      "currency" => "USD",
      "quantity" => 1,
      "rokuCustomerId" => "abcdefghijklmnop",
      "expirationDate" => "2012-08-22T14:59:50",
      "originalPurchaseDate" => "2010-08-22T14:59:50",
      "status" => "Success",
      "errorMessage" => "error_message"
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

    assert RokuIAP.cancel_subscription("k_1", "t_3", "p_1", cancellation_date) ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: response
        }
      }

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
      "transactionId" => "t_2",
      "purchaseDate" => "2012-07-22T14:59:50",
      "channelName" => "123Video",
      "productName" => "123Video Monthly Subscription",
      "productId" => "NETMONTH",
      "amount" => 9.99,
      "currency" => "USD",
      "quantity" => 1,
      "rokuCustomerId" => "abcdefghijklmnop",
      "expirationDate" => "2012-08-22T14:59:50",
      "originalPurchaseDate" => "2010-08-22T14:59:50",
      "status" => "Success",
      "errorMessage" => "error_message"
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

    assert RokuIAP.refund_subscription("k_1", "t_3", "p_1", 6.66, "cuz roku") ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: response
        }
      }

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
      "errorCode" => "",
      "errorDetails" => "",
      "errorMessage" => "",
      "status" => 0
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

    assert RokuIAP.update_bill_cycle("k_1", "t_3", billing_cycle_date) ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: response
        }
      }

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
      "errorCode" => "",
      "errorDetails" => "",
      "errorMessage" => "",
      "status" => 0,
      "ReferenceId" => "Ref1"
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

    assert RokuIAP.issue_service_credit("k_1", "c_1", "p_r_1", "p_1", "r_c_1", 6.66, "cuz roku") ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: response
        }
      }

    assert validate :hackney
  end
end
