defmodule Tweetyodel.Worker.Supervisor do
  use DynamicSupervisor

  def start_link do
    # We are now registering our supervisor process with a name
    # so we can reference it in the `start_tweet/1` function
    DynamicSupervisor.start_link(__MODULE__, [], name: :tweet_supervisor)
  end

  def start_tweet(name) do
    spec = Supervisor.Spec.worker(Tweetyodel.Worker, [name])
    DynamicSupervisor.start_child(:tweet_supervisor, spec)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
