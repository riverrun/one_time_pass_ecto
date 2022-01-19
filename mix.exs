defmodule OneTimePassEcto.Mixfile do
  use Mix.Project

  @version "1.1.1"

  @description """
  One-time password library for Elixir
  """

  def project do
    [
      app: :one_time_pass_ecto,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
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
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.13", optional: true},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["David Whitlock"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/riverrun/one_time_pass_ecto"}
    ]
  end
end
