defmodule HedwigSMS.Mixfile do
  use Mix.Project

  def project do
    [app: :hedwig_sms,
     name: "Hedwig SMS",
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     docs: [
       extras: ["README.md"]
     ]
    ]
  end

  def application do
    [applications: [:logger, :hedwig, :cowboy, :httpoison]]
  end

  defp deps do
    [
      {:hedwig, github: "hedwig-im/hedwig"},
      {:httpoison, "~> 0.8.0"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.1"},
      {:earmark, "~> 0.2", only: :dev },
      {:ex_doc, "~> 0.11", only: :dev },
      {:credo, "~> 0.2.0", only: :dev }
    ]
  end
end
