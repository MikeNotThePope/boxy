defmodule Boxy.MixProject do
  use Mix.Project

  def project do
    [
      app: :boxy,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phx_new, "~> 1.7.14", runtime: false}
    ]
  end

  defp aliases do
    [
      test: ["boxy.test_boxy", "boxy.test_app"],
      precommit: ["boxy.pedant", "format --check-formatted", "boxy.test.all"]
    ]
  end
end
