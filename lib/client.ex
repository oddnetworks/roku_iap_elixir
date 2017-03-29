defmodule RokuIAP.Client do
  use HTTPoison.Base

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
end