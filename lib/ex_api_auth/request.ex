defmodule ExApiAuth.Request do
  defstruct method:       "GET",
            body:         nil,
            content_md5:  nil,
            content_type: "",
            uri:          "/",
            date:         :httpd_util.rfc1123_date

  @type r :: %__MODULE__{}
  @type c :: %Plug.Conn{}

  @doc """
    Decomposes an HTTP request into a string representation for signing.

    Can take either `%ExApiAuth.Request{}` or `%Plug.Conn{}` as an input
  """
  def canonical_string(request)

  @spec canonical_string(c) :: binary
  def canonical_string(%Plug.Conn{} = conn) do
    req = %ExApiAuth.Request{
      method:       conn.method,
      uri:          parse_uri(conn),
      content_md5:  conn |> Plug.Conn.get_req_header("content_md5")  |> List.first,
      content_type: conn |> Plug.Conn.get_req_header("content_type") |> List.first,
      date:         conn |> Plug.Conn.get_req_header("date")         |> List.first
    }

    canonical_string(req)
  end

  @spec canonical_string(r) :: binary

  def canonical_string(%ExApiAuth.Request{content_md5: nil} = req) do
    md5 = case req.body do
      nil  -> ""
      body -> :crypto.hash(:md5, body) |> Base.encode64
    end

    canonical_string(%{req | content_md5: md5})
  end

  def canonical_string(%ExApiAuth.Request{} = req) do
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
