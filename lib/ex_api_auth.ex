defmodule ExApiAuth do
  def sign!(request, access_id, secret_key) do
  end

  @spec sign!(binary, binary) :: binary
  def sign!(canonical_string, secret) do
    :crypto.hmac(:sha, secret, canonical_string) |> Base.encode64
  end

  def authentic?(signed_request, secret_key) do
  end

  @type conn :: %Plug.Conn{}

  @spec access_id(conn) :: binary | nil
  def access_id(%Plug.Conn{req_headers: headers}) do
    case get_access_id_and_signed_string(headers["authorization"]) do
      [access_id, _] -> access_id
      nil -> nil
    end
  end

  defp get_access_id_and_signed_string(nil), do: nil
  defp get_access_id_and_signed_string(auth_header) when is_binary auth_header do
    Regex.run(~r{APIAuth ([^:]+):(.+)$}, auth_header, capture: :all_but_first)
  end

  defp canonical_string(method, "", headers, body) do
    canonical_string(method, "/", headers, body)
  end

  defp canonical_string(method, uri, headers, "") do
    canonical_string(method, uri, headers)
  end

  defp canonical_string(method, uri, headers) do
    [
      String.upcase(method),
      headers["content-type"],
      headers["content-md5"],
      uri,
      headers["date"]
    ] |> Enum.join(",")
  end

  defp parse_uri(%Plug.Conn{request_path: request_path, query_string: ""}) do
    request_path
  end

  defp parse_uri(%Plug.Conn{request_path: request_path, query_string: query_string}) do
    "#{request_path}?#{query_string}"
  end
end
