defmodule ExAPIAuth do
  @moduledoc """
  """

  alias ExAPIAuth.Request

  @type c :: %Plug.Conn{}
  @type r :: %Request{}

  @doc """
  Generates a random Base64 encoded secret key

  Store this key along with the access key that will be used for
  authenticating the client
  """
  @spec generate_secret_key :: binary
  def generate_secret_key do
    :sha512 |> :crypto.hash(:crypto.strong_rand_bytes(512)) |> Base.encode64
  end

  @doc """
  Signs a `request` using the client's `access_id` and `secret_key`.

  Returns a valid authorization header, which you must *manually* add to your HTTP request.

  ## Examples:
    iex> req = %ExAPIAuth.Request{date: "Sun, 11 Sep 2016 00:11:51 GMT"}
    ...> ExAPIAuth.sign!(req, "tenant", "secret")
    "APIAuth tenant:dcVrINe+HMhGTis8K6TPB2f/n+c="
  """
  @spec sign!(r, binary, binary) :: binary
  def sign!(%Request{} = request, access_id, secret_key) do
    signature = sign!(Request.canonical_string(request), secret_key)

    "APIAuth #{access_id}:#{signature}"
  end

  @spec sign!(binary, binary) :: binary
  defp sign!(canonical_string, secret) do
    :sha |> :crypto.hmac(secret, canonical_string) |> Base.encode64
  end

  @doc """
  Determines if the request is authentic given the request and the client's
  secret key. Returns `true` if the request is authentic and `false` otherwise.

  ## Examples:
    iex> ExAPIAuth.authentic?(%Plug.Conn{}, "secret")
    false
  """
  @spec authentic?(c, binary) :: boolean
  def authentic?(%Plug.Conn{} = conn, secret_key) do
    case parse_header(conn) do
      [_, signature] ->
        authentic?(Request.canonical_string(conn), secret_key, signature)
      _ ->
        false
    end
  end

  @spec authentic?(binary, binary, binary) :: boolean
  defp authentic?(canonical_string, secret_key, signature) do
    sign!(canonical_string, secret_key) == signature
  end

  @doc """
  Returns the access id from the request's authorization header if present,
  otherwise `nil`

  ## Examples:

    iex> conn = %Plug.Conn{req_headers: [{"authorization", "ApiAuth foo:bar"}]}
    ...> ExAPIAuth.access_id(conn)
    "foo"

    iex> ExAPIAuth.access_id(%Plug.Conn{})
    nil
  """
  @spec access_id(c) :: binary | nil
  def access_id(%Plug.Conn{} = conn) do
    case parse_header(conn) do
      [match, _] -> match
      nil -> nil
    end
  end

  @spec parse_header(c) :: [binary] | nil
  defp parse_header(%Plug.Conn{} = conn) do
    parse_header(conn |> Plug.Conn.get_req_header("authorization") |> List.first)
  end

  @spec parse_header(nil) :: nil
  defp parse_header(nil), do: nil

  @spec parse_header(binary) :: [binary] | nil
  defp parse_header(auth_header) when is_binary auth_header do
    Regex.run(~r{^\w+ ([^:]+):(.+)$}, auth_header, capture: :all_but_first)
  end
end
