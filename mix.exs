defmodule Tweetyodel.Mixfile do
  use Mix.Project

  def project do
    [app: :tweetyodel,
     version: "0.1.0",
     elixir: "~> 1.3",
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

  defp deps do
    [
      {:oauth, github: "tim/erlang-oauth"},
      {:extwitter, "~> 0.7.1"},
      {:gproc, "~> 0.5.0"}
    ]
  end
end
