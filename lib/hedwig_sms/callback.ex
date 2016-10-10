if Code.ensure_loaded?(Plug.Conn) and Code.ensure_loaded?(Plug.Adapters.Cowboy) do

  defmodule Hedwig.Adapters.SMS.Callback do
    @moduledoc """
    Defines a Plug and HTTP server to be used as a callback endpoint
    for Twilio. Use this if you do not already have an endpoint to use.
    accepts posts to the `/` path. Builds message from callback body and sends it
    to the robot
    """

    use Plug.Builder
    require Logger

    plug Plug.Logger

    @spec start_link(atom, module) :: GenServer.on_start
    def start_link(otp_app, robot) do
      start_link(otp_app, robot, [port: 4000])
    end

    @spec start_link(atom, module, Keyword.t) :: GenServer.on_start
    def start_link(otp_app, robot, cowboy_options) do
      plug_opts = [name: Application.get_env(otp_app, robot)[:name]]
      Plug.Adapters.Cowboy.http __MODULE__, plug_opts, cowboy_options
    end

    @doc false
    def init(options) do
      options
    end

    @doc false
    def call(%Plug.Conn{ request_path: "/", method: "POST" } = conn, opts) do
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      case Hedwig.Adapters.SMS.handle_in(body) do
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
