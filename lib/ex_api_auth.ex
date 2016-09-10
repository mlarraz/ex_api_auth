defmodule ExApiAuth do
  alias ExApiAuth.Request

  @type conn :: %Plug.Conn{}
  @type req  :: %ExApiAuth.Request{}

  @spec sign!(req, binary, binary) :: binary
  def sign!(%Request{} = request, access_id, secret_key) do
    signature = sign!(Request.canonical_string(request), secret_key)

    "APIAuth #{access_id}:#{signature}"
  end

  @spec sign!(binary, binary) :: binary
  defp sign!(canonical_string, secret) do
    :crypto.hmac(:sha, secret, canonical_string) |> Base.encode64
  end

  @spec authentic?(conn, binary) :: boolean
  def authentic?(%Plug.Conn{} = conn, secret_key) do
    case parse_header(conn) do
      [_, signature] ->
        authentic?(conn, secret_key, signature)
      _ ->
        false
    end
  end

  defp authentic?(conn, secret_key, signature) do
    sign!(Request.canonical_string(conn), secret_key) == signature
  end

  @spec access_id(conn) :: binary | nil
  def access_id(%Plug.Conn{} = conn) do
    case parse_header(conn) do
      [access_id, _] -> access_id
      nil -> nil
    end
  end

  defp parse_header(nil), do: nil

  defp parse_header(%Plug.Conn{} = conn) do
    parse_header(conn |> Plug.Conn.get_req_header("authorization") |> List.first)
  end

  @spec parse_header(binary) :: [binary] | nil
  defp parse_header(auth_header) when is_binary auth_header do
    Regex.run(~r{APIAuth ([^:]+):(.+)$}, auth_header, capture: :all_but_first)
  end
end
