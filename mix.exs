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
     ],
     description: "A SMS adapter for Hedwig powered by Twilio",
     source_url: "https://github.com/bryanjos/hedwig_sms"
    ]
  end

  def application do
    [applications: [:logger, :hedwig, :httpoison]]
  end

  defp deps do
    [
      {:hedwig, "~> 1.0.0-rc.4"},
      {:httpoison, "~> 0.8.0"},
      {:cowboy, "~> 1.0", optional: true},
      {:plug, "~> 1.1", optional: true},
      {:earmark, "~> 0.2", only: :dev },
      {:ex_doc, "~> 0.11", only: :dev },
      {:credo, "~> 0.2.0", only: :dev }
    ]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Bryan Joseph"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/bryanjos/hedwig_sms",
     }]
  end
end
