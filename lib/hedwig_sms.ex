defmodule Hedwig.Adapters.SMS do
  use Hedwig.Adapter
  require Logger

  defmodule State do
    defstruct account_sid: nil,
    account_token: nil,
    account_number: nil,
    robot: nil
  end


  def init({robot, opts}) do
    Hedwig.Robot.register(robot, opts[:name])

    state = %State{
      account_sid: opts[:account_sid],
      account_token: opts[:auth_token],
      account_number: opts[:account_number],
      robot: robot
    }

    { :ok, state }
  end

  def handle_cast({:emote, msg}, state) do
    send_message(msg.user, msg.text, state)
    {:noreply, state}
  end

  def handle_cast({:reply, msg}, state) do
    send_message(msg.user, msg.text, state)
    {:noreply, state}
  end

  def handle_cast({:send, msg}, state) do
    send_message(msg.user, msg.text, state)
    {:noreply, state}
  end

  def handle_info({:message, ""}, state) do
    {:noreply, state}
  end

  @doc false
  def handle_info({:message, %Hedwig.Adapters.SMS.Data{ body: body, from: from } }, %{robot: robot} = state) do
    msg = %Hedwig.Message{
      adapter: {__MODULE__, self},
      ref: make_ref(),
      text: body,
      type: "chat",
      user: from
    }

    Hedwig.Robot.handle_message(robot, msg)

    {:noreply, state}
  end

  defp send_message(phone_number, body, state) do
    Logger.info "sending #{body} to #{phone_number}"
    endpoint = "https://#{state.account_sid}:#{state.account_token}@api.twilio.com/2010-04-01/Accounts/#{state.account_sid}/Messages.json"
    body = URI.encode("To=#{phone_number}&From=#{state.account_number}&Body=#{body}")
    headers = [{"Content-Type", "application/x-www-form-urlencoded" }]

    case HTTPoison.post!(endpoint, body, headers) do
      %HTTPoison.Response{status_code: status_code} = response when status_code in 200..299 ->
        Logger.info("#{inspect response}")

      %HTTPoison.Response{status_code: status_code} = response when status_code in 400..599 ->
        Logger.error("#{inspect response}")
    end
  end
end
