defmodule Tweetyodel.Worker do
  use GenServer

  @max_keep_tweets 100

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
    GenServer.call(via_tuple(namespace), %{start_stream: topic})
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
    GenServer.call(via_tuple(namespace), :stop_stream)
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

  def handle_call(%{search: topic}, _from, state) do
    tweets = ExTwitter.search(topic)
    {:reply, tweets, Map.put(state, :tweets, tweets)}
  end

  def handle_call(:entries, _from, state) do
    {:reply, Enum.reverse(Map.get(state, :tweets, [])), state}
  end

  def handle_call(:stop_stream, _from, %{stream: stream_pid, tweets: tweets}) do
    ExTwitter.stream_control(stream_pid, :stop)
    Process.exit(stream_pid, :normal)
    {:reply, :ok, %{tweets: tweets}}
  end

  def handle_call(:stop_stream, _from, state) do
    {:reply, :stream_not_started, state}
  end

  def handle_call(%{start_stream: topic}, _from, state) do
    schedule_work(topic)
    {:reply, :ok, state}
  end

  # Stream already started? just carry on with the state
  def handle_info(%{fetch_tweets: _}, %{stream: _} = state)  do
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
    |> Enum.take(@max_keep_tweets)
    {:noreply, Map.put(state, :tweets, tweets), :hibernate}
  end
end
