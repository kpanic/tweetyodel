defmodule Tweetyodel.Tweets do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    schedule_cleanup()
    {:ok, []}
  end

  def start_topic(pid, topic) do
    GenServer.cast(pid, %{start_tweets: topic})
  end

  defp schedule_cleanup() do
    Process.send_after(self(), :reset_tweets, 60_000 * 1)  # After 5 minutes cleanup
  end

  defp schedule_work(topic) do
    Process.send_after(self(), %{fetch_tweets: topic}, 10_000)
  end

  def entries(pid)  do
    GenServer.call(pid, :entries)
  end

  defp configure_extwitter do
    ExTwitter.configure([
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
      for tweet <- ExTwitter.stream_filter([track: topic], :infinity) do
        send parent, {:tweet, tweet}
      end
    end
    {:noreply, state}
  end

  def handle_info({:tweet, tweet}, state) do
    {:noreply, [tweet|state]}
  end

  def handle_info(:reset_tweets, _state) do
    IO.inspect "resetting!"
    schedule_cleanup()
    {:noreply, [], :hibernate}
  end
end
