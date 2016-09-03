defmodule Tweetyodel.Tweets do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, []}
  end

  def start_topic(pid, topic) do
    GenServer.cast(pid, %{start_tweets: topic})
  end

  defp schedule_work(topic) do
    Process.send_after(self(), %{fetch_tweets: topic}, 10_000)
  end

  def entries(pid)  do
    GenServer.call(pid, :entries)
  end

  defp configure_extwitter do
    ExTwitter.configure(:process, [
          consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
          consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
          access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
          access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
        ]
    )
  end

  def handle_call(:entries, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(%{start_tweets: topic}, state) do
    schedule_work(topic)
    {:noreply, state}
  end

  def handle_info(%{fetch_tweets: topic}, state) do
    parent = self()
    spawn fn ->
      configure_extwitter()
      tweets = ExTwitter.stream_filter([track: topic], :infinity)
      |> Enum.take(10)
      send parent, {:tweets, tweets}
    end
    schedule_work(topic) # Reschedule once more
    {:noreply, state}
  end

  def handle_info({:tweets, tweets}, _state) do
    {:noreply, tweets}
  end
end
