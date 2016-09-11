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

### Signing a request

Assuming you have some credentials:
```elixir
access_id  = "someone"
secret_key = ExAPIAuth.generate_secret_key # or any string you want
```

You can build an `Authorization` header:
```elixir
header = ExAPIAuth.sign!(request, access_id, secret_key)
```

Since most of the Elixir HTTP libraries don't use structs to represent their requests,
we have to rely on the end user to provide us with the input values for the canonical string.

```elixir
request = %ExAPIAuth.Request{
  method:       "GET",

  # from your headers
  content_md5:  "somehash",
  content_type: "application/json",
  date:         "Sun, 11 Sep 2016 00:11:51 GMT"
}
```

This also means we can't mutate a request, so the user is also responsible for setting the header.

### Validating a request

```elixir

```
