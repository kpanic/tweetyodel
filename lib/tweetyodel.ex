defmodule Tweetyodel do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Tweetyodel.Tweets, []),
      supervisor(Tweetyodel.Workers.Supervisor, []),
    ]

    opts = [strategy: :one_for_one, name: Tweetyodel.Supervisor]
    Supervisor.start_link(children, opts)
  end
end