# ExAPIAuth

An Elixir port of [mgomes/api_auth](https://github.com/mgomes/api_auth).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ex_api_auth` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_api_auth, "~> 0.1.0"}]
    end
    ```

  2. Ensure `ex_api_auth` is started before your application:

    ```elixir
    def application do
      [applications: [:ex_api_auth]]
    end
    ```

## Usage

Signing a request:

```elixir
access_id  = "someone"
secret_key = ExAPIAuth.generate_secret_key # or any string you want

# you are responsible for setting the values here
request = %ExAPIAuth.Request{
  method:       "GET",
  body:         "", # optional, only used on non-GET requests if you don't provide an MD5

  # from your headers
  content_md5:  "somehash",
  content_type: "application/json",
  date:         "Sun, 11 Sep 2016 00:11:51 GMT"
}

header = ExAPIAuth.sign!(request, access_id, secret_key)
```

Since most of the Elixir HTTP libraries don't use structs to represent their requests,
we have to rely on the end user to provide us with the input values for the canonical string.
