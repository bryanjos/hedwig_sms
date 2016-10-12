# HedwigSms

An SMS [Hedwig](https://github.com/hedwig-im/hedwig) adapter powered by Twilio.

Refer to the [Create a Robot Module](https://github.com/hedwig-im/hedwig#create-a-robot-module) section for creating a bot.

## Configuration

Below is an example configuration

```elixir
use Mix.Config

config :alfred, Alfred.Robot,
  adapter: Hedwig.Adapters.SMS,
  name: "alfred",
  account_sid: "", #your twilio sid
  auth_token: "", #your twilio auth token
  account_number: "+10000000000", # your twilio number
  responders: [
    {Hedwig.Responders.Help, []},
    {Hedwig.Responders.GreatSuccess, []},
    {Hedwig.Responders.ShipIt, []}
  ]
```

## Twilio Callback
Messages are received from Twilio using an HTTP callback. You can use the included `Hedwig.Adapters.SMS.Callback` module or define one yourself
as long as it calls `Hedwig.Adapters.SMS.handle_in/2` to send the message to the robot.

### Using the included server

To use the included callback with your robot, update your dependencies by including `plug` and `cowboy`:

```elixir
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.1"}
    ]
  end
```

Next, Add cowboy to your list of applications:

```elixir
  def application do
    [applications: [:logger, :hedwig, :cowboy]]
  end
```

Next, add `Hedwig.Adapters.SMS.Callback` to your supervision tree alongside your robot

```elixir
    children = [
      worker(Alfred.Robot, []),
      worker(Hedwig.Adapters.SMS.Callback, [])
    ]
```

Optionally, add the following configuration block to your config to set the `base_path` and/or the `port`

```elixir
config :hedwig_sms, Hedwig.Adapters.SMS.Callback,
  base_path: "/mybasepath" # defaults to "/sms",
  port: 3000 # defaults to 4000
```

### Defining your own callback

If you are defining your own callback (for instance in a phoenix app), just make sure to call `Hedwig.Adapters.SMS.handle_in/2`

```elixir
    def my_twilio_callback(conn, params) do
        case Hedwig.Adapters.SMS.handle_in(robot_name, params) do
            {:error, reason} ->
                # Handle robot not found
            :ok ->
                # Message sent to robot.
       end
    end
```
