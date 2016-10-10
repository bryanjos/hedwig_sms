if Code.ensure_loaded?(Plug.Conn) and Code.ensure_loaded?(Plug.Adapters.Cowboy) do

  defmodule Hedwig.Adapters.SMS.Callback do
    @moduledoc """
    Defines a Plug and HTTP server to be used as a callback endpoint
    for Twilio. Use this if you do not already have an endpoint to use.
    accepts posts to the `/sms/<robot_name>` path where <robot_name> is the name of the robot to handle the message.
    Builds message from callback body and sends it to the robot
    """

    use Plug.Builder
    require Logger

    plug Plug.Logger

    @spec start_link() :: GenServer.on_start
    def start_link() do
      start_link([port: 4000])
    end

    @spec start_link(Keyword.t) :: GenServer.on_start
    def start_link(cowboy_options) do
      Plug.Adapters.Cowboy.http __MODULE__, [], cowboy_options
    end

    @doc false
    def init(options) do
      options
    end

    @doc false
    def call(%Plug.Conn{ request_path: "/sms/" <> robot_name, method: "POST" } = conn, _) do
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      case Hedwig.Adapters.SMS.handle_in(robot_name, body) do
        {:error, _} ->
          conn
          |> send_resp(404, "Not found")
          |> halt
        :ok ->
          conn
          |> send_resp(200, "ok")
          |> halt
      end
    end

    @doc false
    def call(conn, _) do
      conn
      |> send_resp(404, "Not found")
      |> halt
    end

  end
end
