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

header = ExAPIAuth.sign!(request, access_id, secret_key)
```
