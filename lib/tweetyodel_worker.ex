defmodule Tweetyodel.Worker do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:tweet_room, name}}}
  end

  def whereis(room_name) do
    :gproc.whereis_name({:n, :l, {:tweet_room, room_name}})
  end

  def init(_)  do
    schedule_cleanup()
    {:ok, %{}}
  end

  # API

  def start_stream(namespace, topic) do
    GenServer.cast(via_tuple(namespace), %{start_tweets: topic})
  end

  defp schedule_cleanup() do
    Process.send_after(self(), :purge_tweets, 60_000 * 1)
  end

  defp schedule_work(topic) do
    Process.send_after(self(), %{fetch_tweets: topic}, 10_000)
  end

  def entries(namespace)  do
    GenServer.call(via_tuple(namespace), :entries)
  end

  def stop_stream(namespace) do
    GenServer.call(via_tuple(namespace), :stop_tweets)
  end

  def search(namespace, topic) do
    GenServer.call(via_tuple(namespace), %{search: topic})
  end

  # Private

  defp configure_extwitter do
    ExTwitter.configure([
          consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
          consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
          access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
          access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
        ]
    )
  end

  # GenServer

  def handle_call(:entries, _from, state) do
    {:reply, Map.get(state, :tweets, []), state}
  end

  def handle_call(:stop_tweets, _from, state) do
    stream_pid = Map.get(state, :stream)
    if stream_pid do
      ExTwitter.stream_control(stream_pid, :stop)
      Process.exit(stream_pid, :normal)
      {:reply, :ok, state}
    else
      {:reply, :stream_not_started, state}
    end
  end

  def handle_cast(%{start_tweets: topic}, state) do
    schedule_work(topic)
    {:noreply, state}
  end

  def handle_info(%{fetch_tweets: topic}, state) do
    parent = self()
    pid = spawn_link fn ->
      configure_extwitter()
      for tweet <- ExTwitter.stream_filter([track: topic], :infinity) do
        send parent, {:tweet, tweet}
      end
    end
    {:noreply, Map.put(state, :stream, pid)}
  end

  def handle_info({:tweet, tweet}, state) do
    tweets = [tweet|Map.get(state, :tweets, [])]
    {:noreply, Map.put(state, :tweets, tweets)}
  end

  def handle_info(:purge_tweets, state) do
    schedule_cleanup()
    tweets = Map.get(state, :tweets, [])
    |> Enum.take(100)
    {:noreply, Map.put(state, :tweets, tweets), :hibernate}
  end
end
