defmodule Tweetyodel.Mixfile do
  use Mix.Project

  def project do
    [app: :tweetyodel,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :extwitter, :gproc],
    mod: {Tweetyodel, []}]
  end

  defp description do
    """
    Tweetyodel, GenServer for Twitter Search and Streaming API
    """
  end

  defp package do
      [
      files: ["config", "lib", "LICENSE", "mix.exs", "README.md"],
      maintainers: ["Marco Milanesi"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/kpanic/tweetyodel",
               "Contributors" => "https://github.com/kpanic/tweetyodel/graphs/contributors",
               "Issues" => "https://github.com/kpanic/tweetyodel/issues"}
    ]
  end

  defp deps do
    [
      {:oauth, github: "tim/erlang-oauth"},
      {:extwitter, "~> 0.7.1"},
      {:gproc, "~> 0.5.0"}
    ]
  end
end
