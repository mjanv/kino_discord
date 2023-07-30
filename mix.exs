defmodule KinoDiscord.MixProject do
  use Mix.Project

  def project do
    [
      app: :kino_discord,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [mod: {KinoDiscord.Application, []}]
  end

  defp deps do
    [
      {:kino, "~> 0.7"},
      {:req, "~> 0.3"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end
end
