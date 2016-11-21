defmodule Hedwig.Adapters.SMS do
  @moduledoc """
  Hedwig adapter that communicates via SMS using the Twilio API.
  """
  use Hedwig.Adapter
  require Logger

  @doc false
  def init({robot, opts}) do
    HTTPoison.start
    :global.register_name({ __MODULE__, opts[:name] }, self())
    Hedwig.Robot.handle_connect(robot)

    state = %{
      account_sid: opts[:account_sid],
      account_token: opts[:auth_token],
      account_number: opts[:account_number],
      robot: robot
    }

    { :ok, state }
  end

  @doc false
  def handle_cast({:emote, msg}, state) do
    send_message(msg.user, msg.text, state)
    {:noreply, state}
  end

  @doc false
  def handle_cast({:reply, msg}, state) do
    send_message(msg.user, msg.text, state)
    {:noreply, state}
  end

  @doc false
  def handle_cast({:send, msg}, state) do
    send_message(msg.user, msg.text, state)
    {:noreply, state}
  end

  @doc false
  def handle_call(:robot, _, %{robot: robot} = state) do
    {:reply, robot, state}
  end

  defp send_message(phone_number, body, state) do
    Logger.info "sending #{body} to #{phone_number}"
    case build_request(phone_number, body, state) do
      {:ok, %HTTPoison.Response{status_code: status_code} = response } when status_code in 200..299 ->
        Logger.info("#{inspect response}")

      {:ok, %HTTPoison.Response{status_code: status_code} = response } when status_code in 400..599 ->
        Logger.error("#{inspect response}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("#{inspect reason}")
    end
  end

  defp build_request(phone_number, body, state) do
    endpoint = "https://#{state.account_sid}:#{state.account_token}@api.twilio.com/2010-04-01/Accounts/#{state.account_sid}/Messages.json"
    body = URI.encode("To=#{phone_number}&From=#{state.account_number}&Body=#{body}")
    headers = [{"Content-Type", "application/x-www-form-urlencoded" }]
    HTTPoison.post(endpoint, body, headers)
  end


  @doc """
  Sends the Twilio request body from the callback to the robot
  associated with the adapter. `req_body` is assumed to be the post
  body string or a map with keys `"From"` and `"Body"`.

  Use this function if you are defining your own receive callback
  from Twilio
  """
  @spec handle_in(String.t, String.t | Map.t) :: {:error, :not_found} | :ok
  def handle_in(robot_name, req_body) do
    case :global.whereis_name({__MODULE__, robot_name}) do
      :undefined ->
        Logger.error("#{{__MODULE__, robot_name}} not found")
        { :error, :not_found }

      adapter ->
        robot = GenServer.call(adapter, :robot)
        msg = build_message(req_body)
        Hedwig.Robot.handle_in(robot, msg)
    end
  end

  defp build_message(body) when is_binary(body) do
    build_message URI.decode_query(body)
  end

  defp build_message(%{ "From" => user, "Body" => text }) do
    %Hedwig.Message{
      ref: make_ref(),
      text: text,
      type: "chat",
      user: user
    }
  end
end
