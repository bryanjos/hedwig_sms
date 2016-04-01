# HedwigSms

An SMS [Hedwig](https://github.com/hedwig-im/hedwig) adapter powered by Twilio.

In order to receive messages, this adapter also uses cowboy and plug to define an endpoint to be used as your Request URL for your phone number.
You can define the port using the configuration described below.

### Configuration

Below is an example configuration

```elixir
use Mix.Config

config :alfred, Alfred.Robot,
  adapter: Hedwig.Adapters.SMS,
  name: "alfred",
  account_sid: "", #your twilio sid
  auth_token: "", #your twilio auth token
  account_number: "+10000000000", # your twilio number
  port: 4000, # the port used by the callback http server,
  responders: [
    {Hedwig.Responders.Help, []},
    {Hedwig.Responders.Panzy, []},
    {Hedwig.Responders.GreatSuccess, []},
    {Hedwig.Responders.ShipIt, []}
  ]
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add hedwig_sms to your list of dependencies in `mix.exs`:

        def deps do
          [{:hedwig_sms, "~> 0.1.0"}]
        end

  2. Ensure hedwig_sms is started before your application:

        def application do
          [applications: [:hedwig_sms]]
        end

Refer to the [Create a Robot Module](https://github.com/hedwig-im/hedwig#create-a-robot-module) section for creating a bot.
