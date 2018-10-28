defmodule DepsGhqGet.MixProject do
  use Mix.Project

  defp version, do: "0.1.0"

  def project do
    [
      aliases: aliases(),
      app: :deps_ghq_get,
      description:
        "Run `ghq get` and then sync/clone with a GitHub repository that depends on your project.",
      elixir: "~> 1.7.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      start_permanent: Mix.env() == :prod,
      version: version(),
      deps: deps()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19.1", only: :dev}
    ]
  end

  defp aliases do
    [
      "archive.build": ["archive.build -o archives/deps_ghq_get-#{version()}.ez"]
    ]
  end

  defp package do
    [
      name: "deps_ghq_get",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/nabinno/deps_ghq_get"}
    ]
  end
end
