defmodule HedwigSMS.Mixfile do
  use Mix.Project

  def project do
    [app: :hedwig_sms,
     name: "Hedwig SMS"
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :hedwig, :cowboy, :httpoison]]
  end

  defp deps do
    [
      {:hedwig, "~> 1.0.0-rc3"},
      {:httpoison, "~> 0.8.0"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.1"},
      {:poison, "~> 2.1"}
    ]
  end
end
