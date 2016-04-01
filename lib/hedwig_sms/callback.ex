defmodule Hedwig.Adapters.SMS.Callback do
  use Plug.Builder
  require Logger

  plug Plug.Logger

  def start_link(otp_app, robot) do
    start_link(otp_app, robot, [port: 4000])
  end

  def start_link(otp_app, robot, cowboy_opts) do
    plug_opts = [name: Application.get_env(otp_app, robot)[:name]]
    Plug.Adapters.Cowboy.http __MODULE__, plug_opts, cowboy_opts
  end

  def init(options) do
    options
  end

  def call(%Plug.Conn{ request_path: "/", method: "POST" } = conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    data = Hedwig.Adapters.SMS.Data.to_data(body)

    case Hedwig.whereis(opts[:name]) do
      :undefined ->
        Logger.error("Robot named #{opts[:name]} not found")

        conn
        |> send_resp(404, "Not found")
        |> halt

      pid ->
        IO.inspect({ pid, { :message, data }  } )
        Kernel.send pid, { :message, data }
        conn
        |> send_resp(200, "ok")
        |> halt
    end
  end

  def call(conn, opts) do
    conn
    |> send_resp(404, "Not found")
    |> halt
  end




end
