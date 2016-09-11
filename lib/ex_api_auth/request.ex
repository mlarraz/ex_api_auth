defmodule ExAPIAuth.Request do
  @moduledoc """
  Prepares an existing HTTP request for signing

  ## Struct
  The relevant subset of an HTTP request.

  It is the user's responsibility to populate this
  with the same data as the actual request they
  plan on making.

  * `method` - the request method as a binary, defaults to "GET"
  * `uri` - the request path, including query string if present
  * `content_md5` - the value of the request's "content_md5" header
  * `content_type` - the value of the request's "content_type" header
  * `date` - the value of the request's "date" header
  """

  defstruct method:       "GET",
            content_md5:  nil,
            content_type: "",
            uri:          "/",
            date:         nil

  @type r :: %__MODULE__{}
  @type c :: %Plug.Conn{}

  @doc """
  Decomposes an HTTP request into a string representation for signing.

  Can take either `%ExAPIAuth.Request{}` or `%Plug.Conn{}` as an input

  ## Examples
    iex> conn = %Plug.Conn{
    ...>   method: "POST", request_path: "/status", req_headers: [
    ...>     {"date", "Sun, 11 Sep 2016 00:11:51 GMT"},
    ...>     {"content_md5", "1B2M2Y8AsgTpgAmY7PhCfg=="},
    ...>     {"content_type", "application/json"}
    ...>   ]
    ...> }
    ...> ExAPIAuth.Request.canonical_string(conn)
    "POST,application/json,1B2M2Y8AsgTpgAmY7PhCfg==,/status,Sun, 11 Sep 2016 00:11:51 GMT"

    iex> req = %ExAPIAuth.Request{date: "Sun, 11 Sep 2016 00:29:56 GMT"}
    ...> ExAPIAuth.Request.canonical_string(req)
    "GET,,,/,Sun, 11 Sep 2016 00:29:56 GMT"
  """
  def canonical_string(request)

  @spec canonical_string(c) :: binary
  def canonical_string(%Plug.Conn{} = conn) do
    req = %__MODULE__{
      method:       conn.method,
      uri:          parse_uri(conn),
      content_md5:  conn |> Plug.Conn.get_req_header("content_md5")  |> List.first,
      content_type: conn |> Plug.Conn.get_req_header("content_type") |> List.first,
      date:         conn |> Plug.Conn.get_req_header("date")         |> List.first
    }

    canonical_string(req)
  end

  @spec canonical_string(r) :: binary
  def canonical_string(%__MODULE__{} = req) do
    [
      String.upcase(req.method),
      req.content_type,
      req.content_md5,
      req.uri,
      req.date
    ] |> Enum.join(",")
  end

  @spec parse_uri(c) :: binary

  defp parse_uri(%Plug.Conn{request_path: request_path, query_string: ""}) do
    request_path
  end

  defp parse_uri(%Plug.Conn{request_path: request_path, query_string: query_string}) do
    "#{request_path}?#{query_string}"
  end
end
