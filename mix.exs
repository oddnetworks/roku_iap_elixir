defmodule RokuIAP.Mixfile do
  use Mix.Project

  def project do
    [app: :roku_iap,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     name: "Roku IAP",
     source_url: "https://github.com/oddnetworks/roku_iap_elixir"]
  end

  def application do
    [applications: [:httpoison],
     extra_applications: [:logger]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.1.0"},
      {:hackney, "~> 1.7.1"},
      {:meck, "~> 0.8.2", only: :test}
    ]
  end

  defp description do
    """
    An Elixir HTTP client for interacting with the Roku IAP REST API
    """
  end

  defp package do
    [name: :roku_iap,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Blain Smith", "Erik Straub"],
     licenses: ["Apache 2.0"],
     links: %{GitHub: "https://github.com/oddnetworks/roku_iap_elixir"}]
  end
end
