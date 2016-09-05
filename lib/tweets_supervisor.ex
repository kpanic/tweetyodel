defmodule Tweetyodel.Worker.Supervisor do
  use Supervisor

  def start_link do
    # We are now registering our supervisor process with a name
    # so we can reference it in the `start_tweet/1` function
    Supervisor.start_link(__MODULE__, [], name: :tweet_supervisor)
  end

  def start_tweet(name) do
    Supervisor.start_child(:tweet_supervisor, [name])
  end

  def init(_) do
    children = [
      worker(Tweetyodel.Worker, [])
    ]

    # We also changed the `strategy` to `simple_one_for_one`.
    # With this strategy, we define just a "template" for a child,
    # no process is started during the Supervisor initialization,
    # just when we call `start_child/2`
    supervise(children, strategy: :simple_one_for_one)
  end
end
