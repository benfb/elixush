defmodule Elixush.Mixfile do
  use Mix.Project

  def project do
    [app: :elixush,
     version: "0.0.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger],
     mod: {Elixush, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.11", only: [:dev]},
      {:zipper, "~> 0.2.0"}
    ]
  end

  defp description do
    """
    A simple Push programming language interpreter implemented in Elixir.
    """
  end

  defp package do
    [
      name: :elixush,
      maintainers: ["Ben Bailey"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/benfb/elixush"}
    ]
  end
end
