defmodule OneTimePassEcto.Mixfile do
  use Mix.Project

  @version "1.0.0"

  @description """
  One-time password library for Elixir
  """

  def project do
    [
      app: :one_time_pass_ecto,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      description: @description,
      package: package(),
      source_url: "https://github.com/riverrun/one_time_pass_ecto",
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13", optional: true},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc,  "~> 0.16", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["David Whitlock"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/riverrun/one_time_pass_ecto",
        "Docs" => "http://hexdocs.pm/one_time_pass_ecto"}
    ]
  end
end
