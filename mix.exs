defmodule HedwigSMS.Mixfile do
  use Mix.Project

  def project do
    [app: :hedwig_sms,
     version: "0.2.0-dev",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     docs: [
       extras: ["README.md"]
     ],
     description: "A SMS adapter for Hedwig",
     source_url: "https://github.com/bryanjos/hedwig_sms",
     package: package()
    ]
  end

  def application do
    [applications: [:logger, :hedwig, :httpoison]]
  end

  defp deps do
    [
      {:hedwig, github: "hedwig-im/hedwig"},
      {:httpoison, "~> 0.8.0"},
      {:cowboy, "~> 1.0", optional: true},
      {:plug, "~> 1.2", optional: true},
      {:earmark, "~> 1.0", only: :dev },
      {:ex_doc, "~> 0.14", only: :dev },
      {:credo, "~> 0.4", only: :dev }
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
