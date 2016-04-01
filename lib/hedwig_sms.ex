defmodule Hedwig.Adapters.SMS do
  use Hedwig.Adapter

  require Logger

  defmodule State do
    defstruct account_sid: nil,
    account_token: nil,
    account_number: nil,
    robot: nil,
    web: nil
  end


  def init({robot, opts}) do
    Hedwig.Robot.register(robot, opts[:name])
    plug_opts = [adapter_pid: self]
    cowboy_opts = Keyword.put([], :port, Keyword.get(opts, :port, 4000))
    {:ok, web} = Plug.Adapters.Cowboy.http Hedwig.Adapters.SMS.Callback, plug_opts, cowboy_opts

    state = %State{
      account_sid: opts[:account_sid],
      account_token: opts[:auth_token],
      account_number: opts[:account_number],
      robot: robot,
      web: web
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
  def handle_info({:message, sms_callback}, %{robot: robot} = state) do
    sms_body = Poison.decode!(sms_callback)

    msg = %Hedwig.Message{
      adapter: {__MODULE__, self},
      ref: make_ref(),
      text: sms_body["Body"],
      type: "chat",
      user: sms_body["From"]
    }

    Hedwig.Robot.handle_message(robot, msg)

    {:noreply, state}
  end

  defp send_message(phone_number, body, state) do
    endpoint = "https://#{state.account_sid}:#{state.account_token}@api.twilio.com/2010-04-01/Accounts/#{state.account_sid}/Messages.json"
    body = URI.encode("To=#{phone_number}&From=#{state.account_number}&Body=#{body}")
    headers = [{"Content-Type", "application/x-www-form-urlencoded" }]

    case HTTPoison.post!(endpoint, body, headers) do
      %HTTPoison.Response{status_code: status_code} when status_code in 200..299 ->
        Logger.debug("Good Request")

      %HTTPoison.Response{status_code: status_code} when status_code in 400..599 ->
        Logger.debug("Bad Request")
    end
  end

  defmodule Callback do
    use Plug.Builder
    require Logger

    plug Plug.Logger

    def init([adapter_pid: _] = options) do
      options
    end

    def call(%Plug.Conn{ request_path: "/", method: "POST" } = conn, opts) do
      Kernel.send opts[:adapter_pid], { :message, conn.body }
      conn
      |> send_resp(200, "ok")
      |> halt
    end

    def call(conn, opts) do
      conn
      |> send_resp(404, "Not found")
      |> halt
    end
  end

end
