# OneTimePassEcto

One-time password library for apps using Ecto.

## Installation

OneTimePassEcto can be installed by adding `one_time_pass_ecto` to your
list of dependencies in `mix.exs`:

## Usage

### Step 1
Add this to your `mix.exs` file

```elixir
def deps do
  [{:one_time_pass_ecto, "~> 1.0"}]
end
```

### Step 2
Read the [module implementation details](https://hexdocs.pm/one_time_pass_ecto/OneTimePassEcto.html#module-implementation-details)

### Step 3

OTPs smaller than 6 digits return `false` when checking them using `OneTimePassEcto.Base.check_totp/3` and ``OneTimePassEcto.Base.check_hotp/3``

#### Using Time-based One Time Passwords(TOTP).

```elixir
iex> secret = OneTimePassEcto.Base.gen_secret(32) # Default secret length is 16
"ZOMPHX3LA5IM64A66RG6YW7ATUFO5D5G"
iex> OneTimePassEcto.Base.gen_totp(s, [{:interval_length, 300}]) # The library generates 6 digit OTP
"679648"
iex> OneTimePassEcto.Base.check_totp("123456", secret, [interval_length: 300]) # Testing a wrong OTP
false
iex> OneTimePassEcto.Base.check_totp("679648", s, [interval_length: 300]) # You can pass token_length in the keyword list. 6 is its default value
5160711 # This is the 'last' value
```

#### Using HMAC-based One Time Passwords

```elixir
iex> secret = OneTimePassEcto.Base.gen_secret(32) # Default secret length is 16
"WXEXLDA6YKUH7CRHU66OGO43JB7SIUF7"
iex> OneTimePassEcto.Base.gen_hotp(secret, 5, [token_length: 6])
"444385"
iex> OneTimePassEcto.Base.check_hotp("354532", secret)
false
iex> OneTimePassEcto.Base.check_hotp("444385", s, [window: 400]) # Set the 'window' in keyword list otherwise you may receive false even with correct OTP
32
```

### Step 4
`OneTimePassEcto.verify/4` can help you persist your generated OTPs in Ecto-supported DBs of your choice. The `params` map is either `%{"id" => id, "hotp" => otp}` or `%{"id" => id, "totp" => otp}`, where `otp` is your generated OTP and `hotp`/`totp` identify the type.